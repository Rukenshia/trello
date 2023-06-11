//
//  TrelloApi.swift
//  trello
//
//  Created by Jan Christophersen on 25.09.22.
//

import Foundation
import Combine
import Alamofire

class TrelloApi: ObservableObject {
  var key: String
  var token: String
  var credentials: [Credential]
  
  @Published var boards: [BasicBoard]
  
  internal var session: Session
  
  @Published var errors: Int = 0
  @Published var errorMessages: [String] = []
  
  static var testing: TrelloApi {
    let prefs = Preferences()
    
    return TrelloApi(key: prefs.trelloKey!, token: prefs.trelloToken!, credentials: prefs.credentials)
  }
  
  init(key: String = "", token: String = "", credentials: [Credential] = []) {
    self.key = key
    self.token = token
    self.credentials = credentials
    self.boards = []
    self.session = Session()
  }
  
  func setAuth(key: String, token: String, credentials: [Credential]) {
    self.key = key
    self.token = token
    self.credentials = credentials
    self.boards = []
    
    if credentials.count > 0 {
      // Use dedicated credentials for board refresh so that we don't need strict rate limiting
      let authAdapter = TrelloApiAuthAdapter(credentials: credentials, boardRefreshCredential: Credential(key: self.key, token: self.token))
      
      self.session = Session(interceptor: Interceptor(adapter: authAdapter, retrier: authAdapter))
    } else {
      
      let authAdapter = TrelloApiAuthAdapter(credentials: [
        Credential(key: self.key, token: self.token)
      ] + credentials)
      self.session = Session(interceptor: Interceptor(adapter: authAdapter, retrier: authAdapter))
    }
  }
  
  static var DateFormatter: ISO8601DateFormatter {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    
    return formatter
  }
  
  static var DateFormatterDate: DateFormatter {
    let formatter = Foundation.DateFormatter()
    formatter.dateFormat = "MMM dd"
    
    return formatter
  }
  
  static var DateFormatterTime: DateFormatter {
    let formatter = Foundation.DateFormatter()
    formatter.dateFormat = "HH:mm"
    
    return formatter
  }
  
  internal func addError(_ error: AFError? = nil) {
    DispatchQueue.main.async {
      self.errors += 1
      
      if let error = error {
        self.errorMessages.append(error.localizedDescription)
      }
    }
  }
  
  internal func request(_ url: String, method: HTTPMethod = .get, parameters: Parameters = [:], completionHandler: @escaping (AFDataResponse<Data?>) -> Void) {
    self.session.request(
      "https://api.trello.com/1\(url)",
      method: method,
      parameters: parameters,
      encoding: URLEncoding.queryString
    )
    .response { response in
      
      if case let .failure(error) = response.result {
        print("API error on '\(url)' \(String(describing: error.responseCode)): \(response)")
        self.addError(error)
        return
      }
      
      DispatchQueue.main.async {
        completionHandler(response)
      }
    }
  }
  
  internal func request<T: Decodable, T2: Encodable>(_ url: String, method: HTTPMethod = .get, parameters: T2, encoder: ParameterEncoder, result: T.Type = T.self, completionHandler: @escaping (AFDataResponse<T>, T  ) -> Void) {
    self.session.request(
      "https://api.trello.com/1\(url)",
      method: method,
      parameters: parameters,
      encoder: encoder
    )
    .responseDecodable(of: result) { response in
      print(String(decoding: response.request!.httpBody!, as: UTF8.self))
      if case let .failure(error) = response.result {
        print("API error on '\(url)' \(String(describing: error.responseCode)): \(response)")
        self.addError(error)
        return
      }
      
      DispatchQueue.main.async {
        completionHandler(response, response.value!)
      }
    }
  }
  
  internal func request<T: Decodable>(_ url: String, method: HTTPMethod = .get, parameters: Parameters = [:], result: T.Type = T.self, completionHandler: @escaping (AFDataResponse<T>, T  ) -> Void) {
    self.session.request(
      "https://api.trello.com/1\(url)",
      method: method,
      parameters: parameters,
      encoding: URLEncoding.queryString
    )
    .responseDecodable(of: result) { response in
      if case let .failure(error) = response.result {
        print("API error on '\(url)' \(String(describing: error.responseCode)) \(String(describing: response.response?.statusCode)): \(response)")
        print(String(decoding: response.data!, as: UTF8.self))
        self.addError(error)
        return
      }
      
      DispatchQueue.main.async {
        completionHandler(response, response.value!)
      }
    }
  }
}

class TrelloApiAuthAdapter: RequestAdapter, RequestRetrier {
  let credentials: [Credential]
  let boardRefreshCredential: Credential?
  
  init(credentials: [Credential], boardRefreshCredential: Credential? = nil) {
    self.credentials = credentials
    self.boardRefreshCredential = boardRefreshCredential
  }
  
  private var credential: Credential {
    credentials.randomElement()!
  }
  
  func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
    var urlRequest = urlRequest
    if let url = urlRequest.url {
      guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
        completion(.success(urlRequest))
        return
      }
      
      var queryItems = components.queryItems ?? []
      
      var cred = credential
      
      if let boardRefreshCredential = boardRefreshCredential {
        do {
          let regex = try NSRegularExpression(pattern: "^\\/1\\/boards\\/[0-9a-fA-F]{24}$", options: [])
          let matches = regex.matches(in: components.path, options: [], range: NSRange(location: 0, length: components.path.count))
          
          if !matches.isEmpty {
            cred = boardRefreshCredential
          }
        } catch {
          print("Invalid regex pattern: \(error.localizedDescription)")
        }
      }
      
      queryItems.append(
        URLQueryItem(name: "key", value: cred.key))
      queryItems.append(
        URLQueryItem(name: "token", value: cred.token)
      )
      
      components.queryItems = queryItems
      
      urlRequest.url = components.url!
    }
    
    completion(.success(urlRequest))
  }
  
  func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
    completion(.doNotRetry)
  }
}
