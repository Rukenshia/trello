//
//  LabelView.swift
//  trello
//
//  Created by Jan Christophersen on 25.09.22.
//

import SwiftUI

struct LabelView: View {
  let label: Label
  var size: CGFloat = 12
  
  var labelFgColor: Color {
    guard let color = label.color else {
      return Color("LabelFg_none");
    }
    
    return Color("LabelFg_\(color)");
  }
  
  var labelBgColor: Color {
    guard let color = label.color else {
      return Color("LabelBg_none");
    }
    
    return Color("LabelBg_\(color)");
  }
  
  var body: some View {
    HStack(spacing: 2) {
      Circle().fill(self.labelFgColor).frame(width: size / 1.5, height: size / 1.5)
      Text(label.name)
        .font(.system(size: size))
        .foregroundColor(Color("LabelText"))
        .lineLimit(1)
    }
    .padding(.horizontal, 4)
    .padding(.vertical, 2)
    .background(self.labelBgColor)
    .cornerRadius(4)
  }
}

struct LabelView_Previews: PreviewProvider {
  static var previews: some View {
    LabelView(label: Label(id: "foo", name: "a label"), size: 12)
  }
}
