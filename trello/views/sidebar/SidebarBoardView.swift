//
//  SidebarBoardView.swift
//  trello
//
//  Created by Jan Christophersen on 08.10.22.
//

import SwiftUI
import Combine

struct SidebarBoardView: View {
  @EnvironmentObject var trelloApi: TrelloApi;
  let board: BasicBoard;
  let starred: Bool;
  @Binding var currentBoard: Board;
  
  @State var isHovering: Bool = false;
  @State var color: Color = Color(.clear);
  
  var body: some View {
    Button(action: {
      trelloApi.getBoard(id: board.id)
    }) {
      HStack {
        Text(board.name)
          .lineLimit(1)
        Spacer()
        if starred {
          Image(systemName: "star.fill")
            .foregroundColor(.yellow)
            .opacity(0.8)
        }
      }
      .contentShape(Rectangle())
      .frame(maxWidth: .infinity)
      .padding(.horizontal, 4)
      .padding(.vertical, 6)
      .background(self.color)
      .cornerRadius(4)
      .onHover(perform: {hover in
        isHovering = hover
        
        withAnimation(.easeInOut(duration: 0.05)) {
          if self.currentBoard.id == self.board.id {
            self.color = .secondary
            return
          }
          
          if hover {
            self.color = .secondary
          } else {
            self.color = Color(.clear)
          }
        }
      })
    }
    .buttonStyle(.plain)
    .onAppear {
      if self.currentBoard.id == self.board.id {
        self.color = .accentColor
      }
    }
    .onReceive(Just(currentBoard)) { newBoard in
      if newBoard.id == self.board.id {
        self.color = .accentColor
      } else {
        if !self.isHovering {
          self.color = Color(.clear)
        }
      }
    }
  }
}

struct SidebarBoardView_Previews: PreviewProvider {
  static var previews: some View {
    SidebarBoardView(board: BasicBoard(id: "abc", name: "one two three", prefs: BoardPrefs()), starred: false, currentBoard: .constant(Board(id: "no-board", idOrganization: "foo", name: "no board", prefs: BoardPrefs(), boardStars: [])))
  }
}
