//
//  TrelloCardApi.swift
//  trello
//
//  Created by Jan Christophersen on 03.11.22.
//

import Foundation
import Alamofire
import AppKit

extension TrelloApi {
  func createCard(listId: String, sourceCardId: String, completion: @escaping (Card) -> Void) {
    self.request("/cards", method: .post, parameters: [
      "idCardSource": sourceCardId,
      "idList": listId,
    ], result: Card.self) { response, card in
      completion(card)
    }
  }
  
  func createCard(listId: String, name: String, description: String, completion: @escaping (Card) -> Void) {
    self.request("/cards", method: .post, parameters: [
      "idList": listId,
      "name": name,
      "desc": description,
    ], result: Card.self) { response, card in
      completion(card)
    }
  }
  
  func getCard(id: String, completion: @escaping (Card) -> Void) {
    self.request("/cards/\(id)", result: Card.self) { response, card in
      completion(card)
    }
  }
  
  func getCardChecklists(id: String, completion: @escaping ([Checklist]) -> Void = { checklists in }) {
    self.request("/cards/\(id)/checklists", result: [Checklist].self) { response, checklists in
      completion(checklists)
    }
  }
  
  func addLabelsToCard(cardId: String, labelIds: [String], completion: @escaping (Card) -> Void) {
    self.getCard(id: cardId) { card in
      self.request("/cards/\(card.id)", method: .put, parameters: [
        "idLabels": (card.idLabels + labelIds).joined(separator: ","),
      ], result: Card.self) { response, card in
        completion(card)
      }
    }
  }
  
  func removeLabelsFromCard(card: Card, labelIds: [String], completion: @escaping (Card) -> Void) {
    self.request("/cards/\(card.id)", method: .put, parameters: [
      "idLabels": card.idLabels.filter{ label in !labelIds.contains(where: { l in l == label }) }.joined(separator: ",")
    ], result: Card.self) { response, card in
      completion(card)
    }
  }
  
  func updateCard(cardId: String, cover: CardCover, completion: @escaping (Card) -> Void) {
    let body: [String: CardCover] = [
      "cover": cover,
    ]
    
    self.request("/cards/\(cardId)", method: .put, parameters: body, encoder: JSONParameterEncoder.default, result: Card.self) { response, card in
      completion(response.value!)
    }
  }
  
  func removeCardCover(cardId: String, completion: @escaping (Card) -> Void) {
    self.request("/cards/\(cardId)", method: .put, parameters: ["cover": ""], encoder: JSONParameterEncoder.default, result: Card.self) { response, card in
      completion(response.value!)
    }
  }
  
  func updateCard(cardId: String, listId: String? = nil, memberIds: [String]? = nil, due: Date? = nil, dueComplete: Bool? = nil, desc: String? = nil, name: String? = nil, pos: Float? = nil, closed: Bool? = nil, completion: @escaping (Card) -> Void) {
    var parameters: Parameters = [:]
    
    if let listId = listId {
      parameters["idList"] = listId
    }
    if let due = due {
      parameters["due"] = TrelloApi.DateFormatter.string(from: due)
    }
    if let dueComplete = dueComplete {
      parameters["dueComplete"] = dueComplete
    }
    if let desc = desc {
      parameters["desc"] = desc
    }
    if let name = name {
      parameters["name"] = name
    }
    if let pos = pos {
      parameters["pos"] = "\(pos)"
    }
    if let memberIds = memberIds {
      parameters["idMembers"] = memberIds
    }
    if let closed = closed {
      parameters["closed"] = closed
    }
    
    self.request("/cards/\(cardId)", method: .put, parameters: parameters, result: Card.self) { response, card in
      completion(response.value!)
    }
  }
  
  func removeCardDue(cardId: String, completion: @escaping (Card) -> Void) {
    self.request("/cards/\(cardId)", method: .put, parameters: ["due": "null"], result: Card.self) { response, card in
      completion(card)
    }
  }
  
  func getCardComments(id: String, completion: @escaping ([ActionCommentCard]) -> Void = { checklists in }) {
    let actions: [ActionCommentCard] = []
    
    self.getCardCommentsPaginated(id: id, page: 0, actions: actions) { actions in
      completion(actions)
    }
  }
  
  func getCardCommentsPaginated(id: String, page: Int, actions: [ActionCommentCard], completion: @escaping ([ActionCommentCard]) -> Void = { checklists in }) {
    self.request("/cards/\(id)/actions", parameters: ["filter": "commentCard,copyCommentCard", "page": page], result: [ActionCommentCard].self) { response, pageActions in
      
      // 50 per page -> we need to paginate again
      if pageActions.count == 50 {
        self.getCardCommentsPaginated(id: id, page: page + 1, actions: actions + pageActions, completion: completion)
        return
      }
      completion(actions + pageActions)
    }
  }
  
  func addCardComment(id: String, text: String, completion: @escaping (ActionCommentCard) -> Void) {
    self.request("/cards/\(id)/actions/comments", method: .post, parameters: ["text": text], result: ActionCommentCard.self) { response, action in
      completion(action)
    }
  }
  
  func updateCardComment(cardId: String, commentId: String, text: String, completion: @escaping (ActionCommentCard) -> Void) {
    self.request("/cards/\(cardId)/actions/\(commentId)/comments", method: .put, parameters: ["text": text], result: ActionCommentCard.self) { response, action in
      completion(action)
    }
  }
  
  func deleteCardComment(cardId: String, commentId: String, completion: @escaping () -> Void) {
    self.request("/cards/\(cardId)/actions/\(commentId)/comments", method: .delete) { response in
      completion()
    }
  }
  
  func getCardAttachments(id: String, completion: @escaping ([Attachment]) -> Void) {
    self.request("/cards/\(id)/attachments", result: [Attachment].self) { response, attachments in
      completion(attachments)
    }
  }
  
  func getCardAttachment(cardId: String, attachmentId: String, completion: @escaping (Attachment) -> Void) {
    self.request("/cards/\(cardId)/attachments/\(attachmentId)", result: Attachment.self) { response, attachment in
      completion(attachment)
    }
  }
  
  func createCardAttachment(cardId: String, name: String, filePath: URL, completion: @escaping (Attachment) -> Void) {
    let url = URL(string: "https://api.trello.com/1/cards/\(cardId)/attachments")!
    
    self.session.upload(multipartFormData: { multiPart in
      multiPart.append(filePath, withName: "file")
    }, to: url)
    .responseDecodable(of: Attachment.self) { response in
      print(String(data: response.data!, encoding: .utf8)!)
      completion(response.value!)
    }
  }
  
  
  func downloadAttachment(url: String, completion: @escaping (Data) -> Void) {
    self.session.request(
      url,
      method: .get,
      headers: [
        "Authorization": "OAuth oauth_consumer_key=\"\(self.key)\", oauth_token=\"\(self.token)\""
      ]
    )
    .response { response in
      if case let .failure(error) = response.result {
        print("API error on '\(url)' \(response.response?.statusCode ?? 0): \(response)")
        self.addError(error)
        return
      }
      
      DispatchQueue.main.async {
        completion(response.data!)
      }
    }
  }
  
  func downloadAttachment(url: String, to: @escaping DownloadRequest.Destination, completion: @escaping () -> Void) {
    self.session.download(
      url,
      method: .get,
      headers: [
        "Authorization": "OAuth oauth_consumer_key=\"\(self.key)\", oauth_token=\"\(self.token)\""
      ],
      to: to
    ).response { response in
      if response.error == nil, let path = response.fileURL {
        NSWorkspace.shared.activateFileViewerSelecting([path])
      }
    }
    
    DispatchQueue.main.async {
      completion()
    }
  }
  
  func deleteCardAttachment(cardId: String, attachmentId: String, completion: @escaping () -> Void) {
    self.request("/cards/\(cardId)/attachments/\(attachmentId)", method: .delete) { response in
      completion()
    }
  }
}
