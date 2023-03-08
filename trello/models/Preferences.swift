//
//  Preferences.swift
//  trello
//
//  Created by Jan Christophersen on 12.10.22.
//

import Foundation

struct PreferenceKeys {
  static let currentBoard = "currentBoard"
  static let trelloKey = "trelloKey"
  static let trelloToken = "trelloToken"
  static let scale = "scale"
  static let organizations = "organizations"
  static let showFavorites = "showFavorites"
}

class OrganizationPreferences: Codable {
  var collapsed: Bool
  
  init(collapsed: Bool) {
    self.collapsed = collapsed
  }
}

class Preferences: ObservableObject {
  var trelloKey: String?;
  var trelloToken: String?;
  var scale: CGFloat;
  @Published var organizations: [String: OrganizationPreferences];
  @Published var showFavorites: Bool;
  
  init() {
    self.trelloKey = UserDefaults.standard.string(forKey: PreferenceKeys.trelloKey);
    self.trelloToken = UserDefaults.standard.string(forKey: PreferenceKeys.trelloToken);
    
    if let orgs = UserDefaults.standard.value(forKey: PreferenceKeys.organizations) as? Data {
      self.organizations = try! PropertyListDecoder().decode([String:OrganizationPreferences].self, from: orgs)
    } else {
      self.organizations = [:]
    }
    
    let storedScale = UserDefaults.standard.float(forKey: PreferenceKeys.scale);
    
    if storedScale == 0 {
      scale = 1.0;
    } else {
      scale = CGFloat(storedScale);
    }
    
    self.showFavorites = UserDefaults.standard.bool(forKey: PreferenceKeys.showFavorites)
    
    $organizations.sink { _ in
      self.save()
    }
  }
  
  func updateShowFavorites(_ value: Bool) {
    self.showFavorites = value
    UserDefaults.standard.set(value, forKey: PreferenceKeys.showFavorites)
  }
  
  func save() {
    UserDefaults.standard.set(self.trelloKey, forKey: PreferenceKeys.trelloKey);
    UserDefaults.standard.set(self.trelloToken, forKey: PreferenceKeys.trelloToken);
    UserDefaults.standard.set(self.scale, forKey: PreferenceKeys.scale);
    
    UserDefaults.standard.set(try? PropertyListEncoder().encode(self.organizations), forKey: PreferenceKeys.organizations);
  }
}
