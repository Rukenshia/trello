//
//  CardDetailsDescriptionView.swift
//  trello
//
//  Created by Jan Christophersen on 01.11.22.
//

import SwiftUI
import MarkdownUI

struct CardDetailsDescriptionView: View {
  @EnvironmentObject var boardVm: BoardState
  @Binding var card: Card
  
  @State private var desc: String = ""
  @State private var editing: Bool = false
  @State private var hovering: Bool = false
  
  @State private var monitor: Any?
  
  var body: some View {
    if self.editing {
      TextEditor(text: $desc)
        .onAppear {
          monitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { nsevent in
            if nsevent.modifierFlags.contains(.command) {
              if nsevent.keyCode == 36 {
                self.editing = false
                
                boardVm.updateCard(cardId: card.id, desc: self.desc)
              }
            }
            
            return nsevent
          }
        }
        .onDisappear {
          if let monitor = self.monitor {
            NSEvent.removeMonitor(monitor)
          }
        }
      
      Button(action: {
        self.editing = false;
        
        boardVm.updateCard(cardId: card.id, desc: self.desc)
      }) {
        Text("Save changes")
          .padding(.horizontal, 12)
          .padding(.vertical, 6)
          .background(Color("TwZinc700"))
          .cornerRadius(4)
      }
      .buttonStyle(.plain)
    } else {
      if self.card.desc.isEmpty {
        HStack {
          Text("_Click to add a description_")
        }
        .padding()
        .onTapGesture {
          self.startEditing()
        }
      } else {
        Markdown(self.card.desc)
          .padding(.horizontal, 6)
          .padding(.vertical, 4)
          .cornerRadius(4)
          .onTapGesture {
            self.startEditing()
          }
      }
    }
  }
  
  private func startEditing() {
    self.editing = true
    self.desc = self.card.desc
  }
}

struct CardDetailsDescriptionView_Previews: PreviewProvider {
  static var previews: some View {
    CardDetailsDescriptionView(card: .constant(Card(id: "id", name: "name")))
  }
}
