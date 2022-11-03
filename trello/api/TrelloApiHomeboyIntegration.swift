//
//  TrelloApiHomeboyIntegration.swift
//  trello
//
//  Created by Jan Christophersen on 03.11.22.
//

import Foundation

extension TrelloApi {
    func markAsDone(card: Card, completion: @escaping (Card) -> Void) {
        guard let doneLabel = self.board.labels.first(where: { label in label.name == "done"}) else {
            fatalError("No done label exists")
        }
        
        self.addLabelsToCard(card: card, labelIds: [doneLabel.id], completion: completion)
    }
}
