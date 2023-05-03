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
          if trelloApi.board.id == self.board.id {
            if hover {
              self.color = Color("CardBackground")
            } else {
              self.color = .accentColor
            }
            return
          }
          
          if hover {
            self.color = Color("CardBackground")
          } else {
            self.color = Color("CardBackground").opacity(0)
          }
        }
      })
    }
    .buttonStyle(.plain)
    .onAppear {
      if trelloApi.board.id == self.board.id {
        self.color = .accentColor
      }
    }
    .onChange(of: trelloApi.board) { newBoard in
      if newBoard.id == self.board.id {
        self.color = .accentColor
      } else {
        self.color = .clear
      }
    }
  }
}

struct SidebarBoardView_Previews: PreviewProvider {
  static var previews: some View {
    SidebarBoardView(board: BasicBoard(id: "abc", name: "one two three", prefs: BoardPrefs()), starred: false)
  }
}
