//
//  Card.swift
//  trello
//
//  Created by Jan Christophersen on 24.09.22.
//

import Foundation

struct Badges: Codable, Hashable {
    var checkItems: Int;
    var checkItemsChecked: Int;
}

struct Card: Identifiable, Codable, Hashable {
    
    var id: String;
    var idList: String = ""; // TODO: remove default
    var labels: [Label] = [];
    var idLabels: [String] = [];
    var name: String;
    var desc: String = "";
    var due: String?;
    var dueComplete: Bool = false;
    var badges: Badges = Badges(checkItems: 0, checkItemsChecked: 0);
    var pos: Float = 0.0;
    
    var dueDate: Date? {
        if self.due == nil {
            return nil;
        }
        
        return TrelloApi.DateFormatter.date(from: self.due!)
    }
}

final class DraggableCard: NSObject, Codable {
    var id: String;
    var idList: String;
    
    init(id: String, idList: String) {
        self.id = id
        self.idList = idList
    }
}
