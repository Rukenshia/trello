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
  case updateCard = "updateCard"
}

struct ActionDataCommentCard: Codable, Hashable {
  var text: String
}

struct ActionDataUpdateCard: Codable, Hashable {
  var old: Old
  var card: Card
  var listBefore: List?
  var listAfter: List?
  
  struct Old: Codable, Hashable {
    var idList: String?
  }
  
  struct List: Codable, Hashable {
    var id: String
  }
  
  struct Card: Codable, Hashable {
    var id: String
  }
}

struct Action: Identifiable, Codable, Hashable {
  var id: String
  var idMemberCreator: String
  var type: ActionType
  var data: Data
  var memberCreator: Member
  var date: String
}

struct ActionCommentCard: Identifiable, Codable, Hashable {
  var id: String
  var idMemberCreator: String
  var type: ActionType
  var data: ActionDataCommentCard
  var memberCreator: Member
  var date: String
}

struct ActionUpdateCard: Identifiable, Codable, Hashable {
  var id: String
  var idMemberCreator: String
  var type: ActionType
  var data: ActionDataUpdateCard
  var memberCreator: Member
  var date: String
}
