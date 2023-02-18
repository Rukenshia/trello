//
//  TrelloListApi.swift
//  trello
//
//  Created by Jan Christophersen on 03.11.22.
//

import Foundation

extension TrelloApi {
    func createList(boardId: String, name: String, completion: @escaping (List) -> Void) {
        self.request("/lists", method: .post, parameters: [
            "idBoard": boardId,
            "name": name,
            "pos": "bottom"
        ], result: List.self) { response, list in
            self.board.lists.append(list)
            completion(list)
        }
    }
    
    func archiveList(listId: String, completion: @escaping () -> Void) {
        self.request("/lists/\(listId)/closed", method: .put, parameters: [
            "value": "true",
        ], result: List.self) { _, _ in
            self.board.lists = self.board.lists.filter{ l in l.id != listId }
            completion()
        }
    }
    
    func setListName(list: List, name: String, completion: @escaping (List) -> Void) {
        self.request("/lists/\(list.id)", method: .put, parameters: [
            "name": name,
        ], result: List.self) { response, list in
            let listIdx = self.board.lists.firstIndex(where: { l in l.id == list.id })!
            
            self.board.lists[listIdx].name = list.name
            
            completion(list)
        }
    }
    
    func moveList(listId: String, pos: String, completion: @escaping (List) -> Void) {
        self.request("/lists/\(listId)", method: .put, parameters: [
            "pos": pos,
        ], result: List.self) { response, list in
            let listIdx = self.board.lists.firstIndex(where: { l in l.id == list.id })!
            
            self.board.lists[listIdx].pos = list.pos
            
            completion(list)
        }
    }
}
