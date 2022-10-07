//
//  Label.swift
//  trello
//
//  Created by Jan Christophersen on 25.09.22.
//

import Foundation

struct Label: Identifiable, Hashable, Codable {
    var id: String;
    var name: String;
    var color: String?;
}
