//
//  Action.swift
//  trello
//
//  Created by Jan Christophersen on 11.11.22.
//

import Foundation

enum ActionType: String, Codable {
  case commentCard = "commentCard"
  case copyCommentCard = "copyCommentCard"
}

struct ActionDataCommentCard: Codable {
  var text: String
}

struct Action: Identifiable, Codable {
  var id: String
  var idMemberCreator: String
  var type: ActionType
  var data: Data
  var memberCreator: Member
  var date: String
}

struct ActionCommentCard: Identifiable, Codable {
  var id: String
  var idMemberCreator: String
  var type: ActionType
  var data: ActionDataCommentCard
  var memberCreator: Member
  var date: String
}
