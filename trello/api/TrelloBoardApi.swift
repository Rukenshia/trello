//
//  TrelloBoardApi.swift
//  trello
//
//  Created by Jan Christophersen on 03.11.22.
//

import Foundation

extension TrelloApi {
    func getBoards(completion: @escaping ([BasicBoard]) -> Void = { boards in }) {
        self.request("/members/me/boards",
                     result: [BasicBoard].self
        ) { response, boards  in
            self.boards = boards
            completion(self.boards)
        }
    }
    
    func getBoard(id: String, completion: @escaping (Board) -> Void = { board in }) {
        self.request("/boards/\(id)",
                     parameters: [
                        "labels": "all",
                        "cards": "open",
                        "lists": "open",
                        "checklists": "all",
                     ],
                     result: Board.self
        ) { response, board in
            var board = board
            
            var listMap = Dictionary(uniqueKeysWithValues: board.lists.map{ ($0.id, $0) })
            
            if !listMap.isEmpty {
                for card in board.cards {
                    if var list = listMap[card.idList] {
                        list.cards.append(card);
                        listMap[card.idList]!.cards.append(card);
                    }
                }
                
                for var (i, list) in board.lists.enumerated() {
                    list.cards = listMap[list.id]!.cards
                    board.lists[i] = list
                }
                
                self.board = board
                completion(self.board)
            }
        }
    }
}
