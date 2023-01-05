//
//  ContentView.swift
//  trello
//
//  Created by Jan Christophersen on 24.09.22.
//

import SwiftUI
import Combine

enum BoardViewType {
  case lists
  case table
}

struct ContentView: View {
  @EnvironmentObject var trelloApi: TrelloApi
  @Binding var showCommandBar: Bool
  
  @State private var cancellable: AnyCancellable?
  @State private var viewType: BoardViewType = .lists
  
  private var timer = Timer.publish(
    every: 10, // second
    on: .main,
    in: .common
  ).autoconnect();
  
  init(showCommandBar: Binding<Bool>) {
    self._showCommandBar = showCommandBar
  }
  
  var body: some View {
    ZStack {
      HStack(alignment: .top, spacing: 0) {
        NavigationView {
          SidebarView()
            .listStyle(SidebarListStyle())
          
          HStack {
            BoardView(board: $trelloApi.board, viewType: $viewType)
            
            RightSidebarView(doneList: $trelloApi.board.lists.first(where: { list in list.name.wrappedValue.contains("✔️") }), board: self.$trelloApi.board).frame(maxWidth: 48)
          }
        }.toolbar {
          ToolbarItem(placement: .navigation) {
            Button(action: {
              NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
            }, label: {
              Image(systemName: "sidebar.leading")
            })
          }
        }
        
      }
      .onAppear {
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
      .toolbar {
        ToolbarBoardVisualisationView(viewType: $viewType)
      }
      .sheet(isPresented: $showCommandBar) {
          VStack {
            CommandBarView()
          }
          .background(.black.opacity(0.8))
          .frame(minWidth: 400, minHeight: 600)
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(showCommandBar: .constant(true))
      .environmentObject(TrelloApi(key: Preferences().trelloKey!, token: Preferences().trelloToken!))
  }
}
