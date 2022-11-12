//
//  Label.swift
//  trello
//
//  Created by Jan Christophersen on 25.09.22.
//

import Foundation
import SwiftUI

struct Label: Identifiable, Hashable, Codable {
  var id: String;
  var name: String;
  var color: String?;
  
  var fgColor: Color {
    guard let color = self.color else {
      return Color("LabelFg_none");
    }
    
    return Color("LabelFg_\(color)");
  }
  
  var bgColor: Color {
    guard let color = self.color else {
      return Color("LabelBg_none");
    }
    
    return Color("LabelBg_\(color)");
  }
}
