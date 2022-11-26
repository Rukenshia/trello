//
//  Attachment.swift
//  trello
//
//  Created by Jan Christophersen on 11.11.22.
//

import Foundation

struct Preview: Identifiable, Hashable, Codable {
  var id: String
  var scaled: Bool
  var url: String
  var bytes: Int
  var height: Int
  var width: Int
}

struct Attachment: Identifiable, Hashable, Codable {
  var id: String
  var bytes: Int
  var date: String
  var edgeColor: String?
  var idMember: String
  var isUpload: Bool
  var mimeType: String?
  var name: String
  var pos: Float
  var previews: [Preview]
  var url: String
}
