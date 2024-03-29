//
//  ContextMenuLabelView.swift
//  trello
//
//  Created by Jan Christophersen on 09.10.22.
//

import SwiftUI

struct ContextMenuLabelView: View {
  @EnvironmentObject var boardVm: BoardState
  
  @Binding var label: Label;
  @Binding var card: Card;
  let applied: Bool;
  
  @State var hovering: Bool = false;
  @State var bgColor: Color = Color(.clear);
  @State var color: Color = Color(.textColor);
  
  private func setColors() {
    if hovering {
      guard let labelColor = label.color else {
        self.bgColor = Color("ButtonBackground");
        self.color = Color(.textColor);
        return;
      }
      
      self.bgColor = Color("LabelBg_\(labelColor)");
      self.color = Color("LabelText");
      return;
    }
    
    guard let labelColor = label.color else {
      self.bgColor = Color(.clear);
      self.color = Color(.textColor);
      return;
    }
    
    self.bgColor = Color("LabelBg_\(labelColor)");
    self.color = Color("LabelText");
    
  }
  
  var body: some View {
    Button(action: {
      if self.applied {
        boardVm.removeLabelsFromCard(card: self.card, labelIds: [label.id])
      } else {
        boardVm.addLabelsToCard(cardId: self.card.id, labelIds: [label.id])
      }
    }) {
      HStack {
        Text(label.name)
          .foregroundColor(self.color)
        Spacer()
        
      }
      .padding(.horizontal, 4)
      .padding(.vertical, 2)
      .background(self.hovering ? self.bgColor.brightness(0.1) : self.bgColor.brightness(0))
      .cornerRadius(4)
    }
    .buttonStyle(.plain)
    .onHover { newHover in
      self.hovering = newHover
      self.setColors()
    }
    .onAppear {
      self.setColors()
    }
  }
}

struct ContextMenuLabelView_Previews: PreviewProvider {
  static var previews: some View {
    ContextMenuLabelView(label: .constant(Label(id: "id", name: "name")), card: .constant(Card(id: "cardid", name: "card")), applied: false)
  }
}
