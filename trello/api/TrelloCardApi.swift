//
//  TrelloCardApi.swift
//  trello
//
//  Created by Jan Christophersen on 03.11.22.
//

import Foundation
import Alamofire

extension TrelloApi {
  func createCard(listId: String, sourceCardId: String, completion: @escaping (Card) -> Void) {
    self.request("/cards", method: .post, parameters: [
      "idCardSource": sourceCardId,
      "idList": listId,
    ], result: Card.self) { response, card in
      let listIdx = self.board.lists.firstIndex(where: { l in l.id == card.idList })!
      
      self.board.lists[listIdx].cards.append(card)
      
      completion(card)
    }
  }
  
  func createCard(list: List, name: String, description: String, completion: @escaping (Card) -> Void) {
    self.request("/cards", method: .post, parameters: [
      "idList": list.id,
      "name": name,
      "desc": description,
    ], result: Card.self) { response, card in
      let listIdx = self.board.lists.firstIndex(where: { l in l.id == card.idList })!
      
      self.board.lists[listIdx].cards.append(card)
      
      completion(card)
    }
  }
  
  func getCardChecklists(id: String, completion: @escaping ([Checklist]) -> Void = { checklists in }) {
    self.request("/cards/\(id)/checklists", result: [Checklist].self) { response, checklists in
      completion(checklists)
    }
  }
  
  func addLabelsToCard(card: Card, labelIds: [String], completion: @escaping (Card) -> Void) {
    self.request("/cards/\(card.id)", method: .put, parameters: [
      "idLabels": (card.idLabels + labelIds).joined(separator: ","),
    ], result: Card.self) { response, card in
      let listIdx = self.board.lists.firstIndex(where: { l in l.id == card.idList })!
      let cardIdx = self.board.lists[listIdx].cards.firstIndex(where: { c in c.id == card.id })!
      
      self.board.lists[listIdx].cards[cardIdx] = card
      completion(card)
    }
  }
  
  func removeLabelsFromCard(card: Card, labelIds: [String], completion: @escaping (Card) -> Void) {
    self.request("/cards/\(card.id)", method: .put, parameters: [
      "idLabels": card.idLabels.filter{ label in !labelIds.contains(where: { l in l == label }) }.joined(separator: ",")
    ], result: Card.self) { response, card in
      let listIdx = self.board.lists.firstIndex(where: { l in l.id == card.idList })!
      let cardIdx = self.board.lists[listIdx].cards.firstIndex(where: { c in c.id == card.id })!
      
      self.board.lists[listIdx].cards[cardIdx] = card
      completion(card)
    }
  }
  
  func updateCard(cardId: String, cover: CardCover, completion: @escaping (Card) -> Void) {
    let body: [String: CardCover] = [
      "cover": cover,
    ]
    
    self.request("/cards/\(cardId)", method: .put, parameters: body, encoder: JSONParameterEncoder.default, result: Card.self) { response, card in
      let listIdx = self.board.lists.firstIndex(where: { l in l.id == card.idList })!
      let cardIdx = self.board.lists[listIdx].cards.firstIndex(where: { c in c.id == card.id })!
      
      self.board.lists[listIdx].cards[cardIdx] = card
      
      completion(response.value!)
    }
  }
  
  func removeCardCover(cardId: String, completion: @escaping (Card) -> Void) {
    self.request("/cards/\(cardId)", method: .put, parameters: ["cover": ""], encoder: JSONParameterEncoder.default, result: Card.self) { response, card in
      let listIdx = self.board.lists.firstIndex(where: { l in l.id == card.idList })!
      let cardIdx = self.board.lists[listIdx].cards.firstIndex(where: { c in c.id == card.id })!
      
      self.board.lists[listIdx].cards[cardIdx] = card
      
      completion(response.value!)
    }
  }
  
  func updateCard(cardId: String, listId: String? = nil, memberIds: [String]? = nil, due: Date? = nil, dueComplete: Bool? = nil, desc: String? = nil, name: String? = nil, pos: Float? = nil, completion: @escaping (Card) -> Void) {
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
      parameters["pos"] = pos
    }
    if let memberIds = memberIds {
      parameters["idMembers"] = memberIds
    }
    
    self.request("/cards/\(cardId)", method: .put, parameters: parameters, result: Card.self) { response, card in
      if let listId = listId {
        // find old card
        if let card = self.board.cards.first(where: { card in card.id == cardId }) {
          
          // Remove from old list and add to new locally
          if let oldList = self.board.lists.firstIndex(where: { list in list.id == card.idList }) {
            self.board.lists[oldList].cards.remove(at: self.board.lists[oldList].cards.firstIndex(of: card)!)
          }
        }
        
        if let newList = self.board.lists.firstIndex(where: { list in list.id == listId }) {
          self.board.lists[newList].cards.append(card)
        }
      } else {
        let listIdx = self.board.lists.firstIndex(where: { l in l.id == card.idList })!
        let cardIdx = self.board.lists[listIdx].cards.firstIndex(where: { c in c.id == card.id })!
        
        self.board.lists[listIdx].cards[cardIdx] = card
      }
      
      completion(response.value!)
    }
  }
  
  func removeCardDue(cardId: String, completion: @escaping (Card) -> Void) {
    self.request("/cards/\(cardId)", method: .put, parameters: ["due": "null"], result: Card.self) { response, card in
      let listIdx = self.board.lists.firstIndex(where: { l in l.id == card.idList })!
      let cardIdx = self.board.lists[listIdx].cards.firstIndex(where: { c in c.id == card.id })!
      
      self.board.lists[listIdx].cards[cardIdx].due = nil
      
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
}
