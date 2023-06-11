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
            completion(list)
        }
    }
    
    func archiveList(listId: String, completion: @escaping () -> Void) {
        self.request("/lists/\(listId)/closed", method: .put, parameters: [
            "value": "true",
        ], result: List.self) { _, _ in
            completion()
        }
    }
    
    func setListName(listId: String, name: String, completion: @escaping (List) -> Void) {
        self.request("/lists/\(listId)", method: .put, parameters: [
            "name": name,
        ], result: List.self) { response, list in
            completion(list)
        }
    }
    
    func moveList(listId: String, pos: String, completion: @escaping (List) -> Void) {
        self.request("/lists/\(listId)", method: .put, parameters: [
            "pos": pos,
        ], result: List.self) { response, list in
            completion(list)
        }
    }
}
