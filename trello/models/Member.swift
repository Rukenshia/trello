//
//  Member.swift
//  trello
//
//  Created by Jan Christophersen on 11.11.22.
//

import Foundation

struct Member: Identifiable, Codable, Hashable {
  var id: String
  var username: String
  var avatarUrl: String?
  var fullName: String
  var initials: String
  var memberType: String?
}
