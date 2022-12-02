//
//  TrelloChecklistApi.swift
//  trello
//
//  Created by Jan Christophersen on 03.11.22.
//

import Foundation

extension TrelloApi {
    func createChecklist(name: String, cardId: String, completion: @escaping (Checklist) -> Void) {
        self.request("/checklists", method: .post, parameters: [
            "idCard": cardId,
            "name": name,
            "pos": "bottom",
        ], result: Checklist.self) { response, checklist in
            
            completion(checklist)
        }
    }
    
    func addCheckItem(checklistId: String, name: String, completion: @escaping (CheckItem) -> Void) {
        self.request("/checklists/\(checklistId)/checkItems", method: .post, parameters: [
            "name": name,
        ], result: CheckItem.self) { response, checkItem in
            completion(checkItem)
        }
    }
    
    func setCheckItemName(cardId: String, checklistId: String, checkItemId: String, name: String, completion: @escaping (CheckItem) -> Void) {
        self.request("/cards/\(cardId)/checklist/\(checklistId)/checkItem/\(checkItemId)", method: .put, parameters: [
            "name": name,
        ], result: CheckItem.self) { response, checkItem in
            completion(checkItem)
        }
    }
    
    func updateCheckItem(cardId: String, checkItem: CheckItem, completion: @escaping (CheckItem) -> Void) {
        self.request("/cards/\(cardId)/checkItem/\(checkItem.id)", method: .put, parameters: [
            "idChecklist": checkItem.idChecklist,
            "name": checkItem.name,
            "state": checkItem.state,
        ], result: CheckItem.self) { response, checkItem in
            completion(checkItem)
        }
    }
    
    func deleteChecklist(checklistId: String, completion: @escaping () -> Void) {
        self.request("/checklists/\(checklistId)", method: .delete, completionHandler: { response in
            completion()
        })
    }
}
