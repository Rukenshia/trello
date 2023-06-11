//
//  TrelloListMenuView.swift
//  trello
//
//  Created by Jan Christophersen on 01.11.22.
//

import SwiftUI

struct TrelloListMenuView: View {
  @EnvironmentObject var boardVm: BoardState
  let listId: String
  
  var body: some View {
    VStack {
      Button(action: {
        boardVm.archiveList(listId: self.listId)
      }) { }
        .buttonStyle(FlatButton(icon: "trash", text: "Delete"))
      Menu("Move list") {
        Text("The list will be moved to the right side of your selection")
        
        Button(action: {
          boardVm.moveList(listId: listId, pos: "top")
        }) {
          Text("-- move to the left --")
        }.buttonStyle(.borderless)
        
        ForEach(self.boardVm.board.lists.filter{ l in l.id != listId }) { ol in
          Button(action: {
            var newPos: CGFloat = 0.0
            let dest = self.boardVm.board.lists.firstIndex(where: {l in l.id == ol.id })!
            
            if dest == self.boardVm.board.lists.count - 1 {
              newPos = self.boardVm.board.lists[self.boardVm.board.lists.count - 1].pos + 1024
            } else {
              newPos = (self.boardVm.board.lists[dest + 1].pos + self.boardVm.board.lists[dest].pos) / 2
            }
            
            boardVm.moveList(listId: listId, pos: "\(newPos)")
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
    TrelloListMenuView(listId: "id")
  }
}
