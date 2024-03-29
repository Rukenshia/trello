//
//  Card.swift
//  trello
//
//  Created by Jan Christophersen on 24.09.22.
//

import Foundation
import SwiftUI
import CodableWrappers

struct Badges: Codable, Hashable {
  var checkItems: Int
  var checkItemsChecked: Int
  var comments: Int
  var attachments: Int
}

struct Card: Identifiable, Codable, Hashable {
  var id: String
  var idList: String = "" // TODO: remove default
  var idBoard: String = "" // TODO: remove default
  var labels: [Label] = []
  var idLabels: [String] = []
  var idMembers: [String] = []
  var name: String
  var desc: String = ""
  var closed: Bool = false
  var due: String?
  var dueComplete: Bool = false
  var badges: Badges = Badges(checkItems: 0, checkItemsChecked: 0, comments: 0, attachments: 0)
  var pos: Float = 0.0
  var dateLastActivity: String = "1991-08-10T00:00:00Z"
  var cover: CardCover?
  
  var dueDate: Date? {
    if self.due == nil {
      return nil
    }
    
    return TrelloApi.DateFormatter.date(from: self.due!)
  }
  
  static var empty: Card {
    return Card(id: "", name: "")
  }
}

struct CardCover: Codable, Hashable {
  @EncodeNulls
  var color: CardCoverColor?
  var size: CardCoverSize
  var brightness: CardCoverBrightness
  var idAttachment: String?
  
  var displayColor: Color {
    switch self.color {
    case .some(let color):
      return Color("CardCover_\(color.rawValue)")
    case .none:
      return Color("CardBackground")
    }
  }
  
  var foregroundColor: Color {
    switch self.color {
    case .some(let color):
      return Color("CardCoverFg_\(color.rawValue)")
    case .none:
      return .primary
    }
  }
}

enum CardCoverColor: String, Codable, CaseIterable {
  case pink = "pink"
  case yellow = "yellow"
  case lime = "lime"
  case blue = "blue"
  case black = "black"
  case orange = "orange"
  case red = "red"
  case purple = "purple"
  case sky = "sky"
  case green = "green"
}

enum CardCoverSize: String, Codable {
  case full = "full"
  case normal = "normal"
}

enum CardCoverBrightness: String, Codable {
  case light = "light"
  case dark = "dark"
}

final class DraggableCard: NSObject, Codable {
  var id: String
  var idList: String
  
  init(id: String, idList: String) {
    self.id = id
    self.idList = idList
  }
}
