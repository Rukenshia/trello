//
//  Preferences.swift
//  trello
//
//  Created by Jan Christophersen on 12.10.22.
//

import Foundation

struct PreferenceKeys {
    static let currentBoard = "currentBoard";
    static let trelloKey = "trelloKey";
    static let trelloToken = "trelloToken";
}

struct Preferences {
    var trelloKey: String?;
    var trelloToken: String?;
    
    init() {
        self.trelloKey = UserDefaults.standard.string(forKey: PreferenceKeys.trelloKey);
        self.trelloToken = UserDefaults.standard.string(forKey: PreferenceKeys.trelloToken);
    }
}
