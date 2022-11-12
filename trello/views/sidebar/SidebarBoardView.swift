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
                        self.color = Color("TwZinc700")
                        return
                    }
                    
                    if hover {
                        self.color = Color("TwZinc800")
                    } else {
                        self.color = Color(.clear)
                    }
                }
            })
        }
        .buttonStyle(.plain)
        .onAppear {
            if self.currentBoard.id == self.board.id {
                self.color = Color("TwZinc700")
            }
        }
        .onReceive(Just(currentBoard)) { newBoard in
            if newBoard.id == self.board.id {
                self.color = Color("TwZinc700")
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
        SidebarBoardView(board: .constant(BasicBoard(id: "abc", name: "one two three", prefs: BoardPrefs())), currentBoard: .constant(Board(id: "no-board", name: "no board", prefs: BoardPrefs())))
    }
}
