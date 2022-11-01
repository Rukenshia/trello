//
//  List.swift
//  trello
//
//  Created by Jan Christophersen on 24.09.22.
//

import Foundation

struct List: Identifiable, Codable, Hashable {
    var id: String;
    var name: String;
    var cards: [Card] = [];
    var pos: CGFloat = 0.0
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case pos
    }
}
