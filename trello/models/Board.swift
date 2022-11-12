//
//  Board.swift
//  trello
//
//  Created by Jan Christophersen on 25.09.22.
//

import Foundation

struct BoardPrefs: Codable {
  var backgroundImage: String? = nil
}

struct BasicBoard: Identifiable, Codable {
  var id: String
  var name: String
  var prefs: BoardPrefs
}

struct Board: Identifiable, Codable {
  var id: String
  var name: String
  var prefs: BoardPrefs
  
  var lists: [List] = []
  var cards: [Card] = []
  var labels: [Label] = []
  var members: [Member] = []
  
}
