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
  static let scale = "scale";
}

struct Preferences {
    var trelloKey: String?;
    var trelloToken: String?;
  var scale: CGFloat;
    
    init() {
        self.trelloKey = UserDefaults.standard.string(forKey: PreferenceKeys.trelloKey);
        self.trelloToken = UserDefaults.standard.string(forKey: PreferenceKeys.trelloToken);
      let storedScale = UserDefaults.standard.float(forKey: PreferenceKeys.scale);
      
      if storedScale == 0 {
        scale = 1.0;
      } else {
        scale = CGFloat(storedScale);
      }
    }
    
    func save() {
        UserDefaults.standard.set(self.trelloKey, forKey: PreferenceKeys.trelloKey);
      UserDefaults.standard.set(self.trelloToken, forKey: PreferenceKeys.trelloToken);
      UserDefaults.standard.set(self.scale, forKey: PreferenceKeys.scale);
    }
}
