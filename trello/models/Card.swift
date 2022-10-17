//
//  Card.swift
//  trello
//
//  Created by Jan Christophersen on 24.09.22.
//

import Foundation

struct Card: Identifiable, Codable, Hashable {
    
    var id: String;
    var idList: String = ""; // TODO: remove default
    var labels: [Label] = [];
    var idLabels: [String] = [];
    var name: String;
    var desc: String = "";
    var due: String?;
    var dueComplete: Bool = false;
    
    var dueDate: Date? {
        if self.due == nil {
            return nil;
        }
        
        return TrelloApi.DateFormatter.date(from: self.due!)
    }
}
