//
//  ContentView.swift
//  trello
//
//  Created by Jan Christophersen on 24.09.22.
//

import SwiftUI
import Combine

struct ContentView: View {
    @EnvironmentObject var trelloApi: TrelloApi;
    
    @State private var cancellable: AnyCancellable?;
    
    private var timer = Timer.publish(
        every: 10, // second
        on: .main,
        in: .common
    ).autoconnect();
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            SidebarView()
            
            BoardView(board: $trelloApi.board)
            
            RightSidebarView(doneList: $trelloApi.board.lists.first(where: { list in list.name.wrappedValue.contains("✔️") })).frame(maxWidth: 48)
        }.onAppear {
            self.cancellable = trelloApi.$board.sink { newBoard in
                if newBoard.id == "" {
                    return
                }
                
                UserDefaults.standard.set(newBoard.id, forKey: PreferenceKeys.currentBoard)
            }
            
            trelloApi.getBoards { boards in
                if let currentBoard = UserDefaults.standard.string(forKey: PreferenceKeys.currentBoard) {
                    if currentBoard.isEmpty {
                        if (boards.count > 0) {
                            trelloApi.getBoard(id: boards[0].id)
                        }
                    } else {
                        trelloApi.getBoard(id: currentBoard)
                    }
                } else {
                    if (boards.count > 0) {
                        trelloApi.getBoard(id: boards[0].id)
                    }
                }
            }
        }
        .frame(minWidth: 900, minHeight: 600, alignment: .top)
        .onReceive(timer) { newTime in
            self.trelloApi.getBoard(id: self.trelloApi.board.id) { board in
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(TrelloApi(key: Preferences().trelloKey!, token: Preferences().trelloToken!))
    }
}
