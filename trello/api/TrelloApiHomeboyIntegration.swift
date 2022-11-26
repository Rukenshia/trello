//
//  TrelloApiHomeboyIntegration.swift
//  trello
//
//  Created by Jan Christophersen on 03.11.22.
//

import Foundation

extension TrelloApi {
  func markAsDone(card: Card, completion: @escaping (Card) -> Void) {
    self.updateCard(cardId: card.id, dueComplete: true) { newCard in
      guard let doneLabel = self.board.labels.first(where: { label in label.name == "done"}) else {
        completion(newCard)
        return
      }
      
      self.addLabelsToCard(card: card, labelIds: [doneLabel.id], completion: { card in
        // Remove the card from the current list so that it doesn't take so long for the UI to update
        let listIdx = self.board.lists.firstIndex(where: {l in l.id == card.idList})!
        self.board.lists[listIdx].cards.removeAll(where: { c in c.id == card.id })
        
        completion(card)
      })
    }
    
  }
}
