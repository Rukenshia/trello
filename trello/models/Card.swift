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
    var checkItems: Int;
    var checkItemsChecked: Int;
}

struct Card: Identifiable, Codable, Hashable {
    var id: String;
    var idList: String = ""; // TODO: remove default
    var labels: [Label] = [];
    var idLabels: [String] = [];
    var name: String;
    var desc: String = "";
    var due: String?;
    var dueComplete: Bool = false;
    var badges: Badges = Badges(checkItems: 0, checkItemsChecked: 0);
    var pos: Float = 0.0;
    var dateLastActivity: String = "1991-08-10T00:00:00Z";
    var cover: CardCover?
    
    var dueDate: Date? {
        if self.due == nil {
            return nil;
        }
        
        return TrelloApi.DateFormatter.date(from: self.due!)
    }
}

struct CardCover: Codable, Hashable {
    @EncodeNulls
    var color: CardCoverColor?
    var size: CardCoverSize
    var brightness: CardCoverBrightness
    
    var displayColor: Color {
        switch self.color {
        case .red:
            return Color("TwRed700")
        case .some(.pink):
            return Color("TwPink500")
        case .some(.yellow):
            return Color("TwYellow600")
        case .some(.lime):
            return Color("TwLime600")
        case .some(.blue):
            return Color("TwBlue700")
        case .some(.black):
            return Color("TwSlate600")
        case .some(.orange):
            return Color("TwAmber600")
        case .some(.purple):
            return Color("TwPurple700")
        case .some(.sky):
            return Color("TwSky600")
        case .some(.green):
            return Color("TwEmerald600")
        case .none:
            return Color.clear
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
    var id: String;
    var idList: String;
    
    init(id: String, idList: String) {
        self.id = id
        self.idList = idList
    }
}
