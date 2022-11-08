//
//  CardDetailsDescriptionView.swift
//  trello
//
//  Created by Jan Christophersen on 01.11.22.
//

import SwiftUI
import MarkdownUI

struct CardDetailsDescriptionView: View {
    @EnvironmentObject var trelloApi: TrelloApi
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
                                
                                self.trelloApi.updateCard(cardId: card.id, desc: self.desc, completion: { newCard in
                                    print("description updated")
                                })
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
                
                self.trelloApi.updateCard(cardId: card.id, desc: self.desc, completion: { newCard in
                    print("description updated")
                })
            }) {
                Text("Save changes")
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color("TwZinc700"))
                    .cornerRadius(4)
            }
            .buttonStyle(.plain)
        } else {
            if !self.card.desc.isEmpty {
                Markdown(self.card.desc)
                    .markdownStyle(MarkdownStyle(foregroundColor: Color("TwStone900")))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)
                    .background(Color("TwZinc200"))
                    .foregroundColor(Color("TwStone900"))
                    .cornerRadius(4)
            }
            
            Button(action: self.startEditing) {
            }
            .buttonStyle(FlatButton(icon: "pencil", text:" Edit"))
            
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
