//
//  Board.swift
//  trello
//
//  Created by Jan Christophersen on 25.09.22.
//

import Foundation

struct BoardPrefs: Codable, Hashable {
  var backgroundImage: String? = nil
  var backgroundTopColor: String? = nil
  var backgroundBottomColor: String? = nil
}

struct BasicBoard: Identifiable, Codable {
  var id: String
  var name: String
  var prefs: BoardPrefs
}

struct Board: Identifiable, Codable, Hashable {
  var id: String
  var name: String
  var prefs: BoardPrefs
  
  var lists: [List] = []
  var cards: [Card] = []
  var labels: [Label] = []
  var members: [Member] = []
  
}
