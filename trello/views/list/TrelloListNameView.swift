//
//  TrelloListNameView.swift
//  trello
//
//  Created by Jan Christophersen on 31.10.22.
//

import SwiftUI

struct TrelloListNameView: View {
    @EnvironmentObject var trelloApi: TrelloApi
    @Binding var list: List
    
    @FocusState private var focusedField: String?
    @State var editing: Bool = false
    @State var newName: String = ""
    @State var hovering: Bool = false
    
    var body: some View {
        HStack {
            HStack {
                if self.editing {
                    Button(action: self.updateName) {
                        
                    }
                    .buttonStyle(IconButton(icon: "checkmark", size: 16))
                    TextField("List name", text: $newName, onCommit: self.updateName)
                        .textFieldStyle(.plain)
                        .focused($focusedField, equals: "name")
                } else {
                    HStack {
                        Text(list.name)
                        if self.hovering {
                            Button(action: {
                                self.editing = true
                                self.focusedField = "name"
                                self.newName = list.name
                            }) {
                            }
                            .buttonStyle(IconButton(icon: "square.and.pencil", size: 16, color: .clear, hoverColor: .clear, padding: 0))
                        }
                    }
                    .onHover { hover in
                        self.hovering = hover
                    }
                    .padding(.horizontal, 4)
                    .padding(.vertical, 4)
                    .background(self.hovering ? Color("TwZinc600") : .clear)
                    .cornerRadius(4)
                }
                Spacer()
            }
                .lineLimit(1)
                .font(.title3)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 8)
            Spacer()
        }
    }
    
    private func updateName() {
        self.editing = false
        
        self.trelloApi.setListName(list: self.list, name: self.newName) { _ in
            
        }
    }
}

struct TrelloListNameView_Previews: PreviewProvider {
    static var previews: some View {
        TrelloListNameView(list: .constant(List(id: "id", name: "card name")))
    }
}
