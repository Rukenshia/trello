//
//  TrelloListMenuView.swift
//  trello
//
//  Created by Jan Christophersen on 01.11.22.
//

import SwiftUI

struct TrelloListMenuView: View {
    @EnvironmentObject var trelloApi: TrelloApi
    @Binding var list: List
    
    var body: some View {
        VStack {
            Button(action: {
                self.trelloApi.archiveList(listId: self.list.id) {}
            }) { }
                .buttonStyle(FlatButton(icon: "trash", text: "Delete"))
            Menu("Move list") {
                Text("The list will be moved to the right side of your selection")
                
                Button(action: {
                    self.trelloApi.moveList(listId: list.id, pos: "top") { list in
                        
                    }
                }) {
                    Text("-- move to the left --")
                }.buttonStyle(.borderless)
                
                ForEach(self.trelloApi.board.lists.filter{ l in l.id != list.id }) { ol in
                    Button(action: {
                        var newPos: CGFloat = 0.0
                        let dest = self.trelloApi.board.lists.firstIndex(where: {l in l.id == ol.id })!
                        
                        if dest == self.trelloApi.board.lists.count - 1 {
                            newPos = self.trelloApi.board.lists[self.trelloApi.board.lists.count - 1].pos + 1024
                        } else {
                            newPos = (self.trelloApi.board.lists[dest + 1].pos + self.trelloApi.board.lists[dest].pos) / 2
                        }
                        
                        self.trelloApi.moveList(listId: list.id, pos: "\(newPos)") { list in
                            
                        }
                    }) {
                        Text(ol.name)
                            .padding(4)
                    }.buttonStyle(.borderless)
                }
            }
        }.padding(8)
    }
}

struct TrelloListMenuView_Previews: PreviewProvider {
    static var previews: some View {
        TrelloListMenuView(list: .constant(List(id: "id", name: "list name")))
    }
}
