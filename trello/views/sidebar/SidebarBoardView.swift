//
//  SidebarBoardView.swift
//  trello
//
//  Created by Jan Christophersen on 08.10.22.
//

import SwiftUI
import Combine

struct SidebarBoardView: View {
  @EnvironmentObject var state: AppState
  let board: BasicBoard;
  let starred: Bool;
  
  var body: some View {
    Button(action: {
      state.selectBoard(id: board.id)
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
      .foregroundColor(state.selectedBoard?.id == self.board.id ? Color.white : Color.primary)
      .background(state.selectedBoard?.id == self.board.id ? Color.accentColor : Color.clear)
      .cornerRadius(4)
    }
    .buttonStyle(.plain)
  }
}

struct SidebarBoardView_Previews: PreviewProvider {
  static var previews: some View {
    SidebarBoardView(board: BasicBoard(id: "abc", idOrganization: "", name: "one two three", prefs: BoardPrefs()), starred: false)
  }
}
