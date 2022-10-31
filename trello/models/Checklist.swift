//
//  Checklist.swift
//  trello
//
//  Created by Jan Christophersen on 17.10.22.
//

import Foundation

struct Checklist: Identifiable, Codable, Hashable {
    var id: String;
    var idCard: String;
    var name: String;
    var checkItems: [CheckItem] = [];
    var pos: CGFloat = 0.0;
}

struct CheckItem: Identifiable, Codable, Hashable {
    var id: String;
    var idChecklist: String;
    var name: String;
    var state: CheckItemState;
}

enum CheckItemState: String, Codable {
    case incomplete = "incomplete"
    case complete = "complete"
}
