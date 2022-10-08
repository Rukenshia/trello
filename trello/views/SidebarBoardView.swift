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
    @Binding var board: BasicBoard;
    @Binding var currentBoard: Board;
    
    @State var color: Color = Color(.clear)
    
    var body: some View {
        Button(action: {
            trelloApi.getBoard(id: board.id)
        }) {
            Text(board.name)
                .lineLimit(1)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .buttonStyle(.plain)
        .padding(.horizontal, 4)
        .padding(.vertical, 6)
        .background(self.color)
        .cornerRadius(4)
        .onHover(perform: {hover in
            withAnimation(.easeInOut(duration: 0.05)) {
                if self.currentBoard.id == self.board.id {
                    self.color = Color("CardBg")
                    return
                }
                
                if hover {
                    self.color = Color("CardBg")
                } else {
                    self.color = Color(.clear)
                }
            }
        })
        .onAppear {
            if self.currentBoard.id == self.board.id {
                self.color = Color("CardBg")
            }
        }
        .onReceive(Just(currentBoard)) { newBoard in
            if newBoard.id == self.board.id {
                self.color = Color("CardBg")
            }
        }
    }
}

struct SidebarBoardView_Previews: PreviewProvider {
    static var previews: some View {
        SidebarBoardView(board: .constant(BasicBoard(id: "abc", name: "one two three", prefs: BoardPrefs())), currentBoard: .constant(Board(id: "no-board", name: "no board", prefs: BoardPrefs())))
    }
}
