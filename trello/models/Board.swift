//
//  Board.swift
//  trello
//
//  Created by Jan Christophersen on 25.09.22.
//

import Foundation

struct BoardPrefs: Codable {
    var backgroundImage: String? = "https://trello-backgrounds.s3.amazonaws.com/54d4b4fc032569bd9870ac0a/original/04b4f28b09473079050638ab87426857/chrome_theme_bg_explorer.jpg";
}

struct BasicBoard: Identifiable, Codable {
    var id: String;
    var name: String;
    var prefs: BoardPrefs;
}

struct Board: Identifiable, Codable {
    var id: String;
    var name: String;
    var prefs: BoardPrefs;
    
    var lists: [List] = [];
    var cards: [Card] = [];
    var labels: [Label] = [];
    
}
