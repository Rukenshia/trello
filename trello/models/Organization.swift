//
//  Organization.swift
//  trello
//
//  Created by Jan Christophersen on 12.11.22.
//

import Foundation

struct Organization: Identifiable, Codable {
  var id: String
  var name: String
  var displayName: String
  var logoUrl: String?
  
  var boards: [BasicBoard] = []
  
  private enum CodingKeys: String, CodingKey {
    case id
    case name
    case displayName
    case logoUrl
  }
}
