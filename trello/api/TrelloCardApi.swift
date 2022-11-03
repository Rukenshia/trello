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
    
    func updateCard(cardId: String, listId: String? = nil, due: Date? = nil, desc: String? = nil, name: String? = nil, pos: Float? = nil, completion: @escaping (Card) -> Void) {
        var parameters: Parameters = [:]
        
        if let listId = listId {
            parameters["idList"] = listId
        }
        if let due = due {
            parameters["due"] = TrelloApi.DateFormatter.string(from: due)
        }
        if let desc = desc {
            parameters["desc"] = desc
        }
        if let name = name {
            parameters["name"] = name
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
            }
            
            completion(response.value!)
        }
    }
}
