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
  let key: String
  let token: String
  
  @Published var board: Board
  @Published var boards: [BasicBoard]
  
  private var session: Session
  
  @Published var errors: Int = 0
  @Published var errorMessages: [String] = []
  
  private var auth: Parameters {
    [
      "key": self.key,
      "token": self.token,
    ]
  }
  
  init(key: String, token: String) {
    self.key = key
    self.token = token
    self.board = Board(id: "", name: "", prefs: BoardPrefs())
    self.boards = []
    
    let authAdapter = TrelloApiAuthAdapter(key: self.key, token: self.token)
    
    self.session = Session(interceptor: Interceptor(adapter: authAdapter, retrier: authAdapter))
  }
  
  static var DateFormatter: ISO8601DateFormatter {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    
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
        print("API error on '\(url)' \(error.responseCode): \(response)")
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
        print("API error on '\(url)' \(error.responseCode): \(response)")
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
        print("API error on '\(url)' \(error.responseCode): \(response)")
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
  let key: String
  let token: String
  
  init(key: String, token: String) {
    self.key = key
    self.token = token
  }
  
  func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
    var urlRequest = urlRequest
    urlRequest.headers.add(name: "x", value: "y")
    if let url = urlRequest.url {
      guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
        completion(.success(urlRequest))
        return
      }
      
      var queryItems = components.queryItems ?? []
      
      queryItems.append(
        URLQueryItem(name: "key", value: self.key))
      queryItems.append(
        URLQueryItem(name: "token", value: self.token)
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
