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
  @EnvironmentObject var state: AppState
  @EnvironmentObject var trelloApi: TrelloApi
  @EnvironmentObject var preferences: Preferences
  @Binding var showCommandBar: Bool
  
  @State private var boardVm: BoardState? = nil
  
  @State private var cancellable: AnyCancellable?
  
  @State private var timer: Publishers.Autoconnect<Timer.TimerPublisher> = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
  
  
  init(showCommandBar: Binding<Bool>) {
    self._showCommandBar = showCommandBar
  }
  
  var body: some View {
    ZStack {
      HStack(alignment: .top, spacing: 0) {
        NavigationView {
          SidebarView()
            .listStyle(SidebarListStyle())
          
          if state.loadingBoard {
            ProgressView()
          } else {
            if let boardVm = boardVm {
              HStack {
                BoardView()
                
                // TODO: add me back
                //              RightSidebarView(doneList: $state.board?.lists.first(where: { list in list.name.wrappedValue.contains("✔️") }), board: self.$state.board?).frame(maxWidth: 48)
              }
              .environmentObject(boardVm)
            }
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
        // Allow a faster refresh when having multiple credentials
        if preferences.credentials.count > 0 {
          timer.upstream.connect().cancel()
          
          timer = Timer.publish(
            every: 3, // second
            on: .main,
            in: .common
          ).autoconnect();
        }
        
        trelloApi.getBoards { boards in
          if let currentBoard = UserDefaults.standard.string(forKey: PreferenceKeys.currentBoard) {
            if currentBoard.isEmpty {
              if (boards.count > 0) {
                state.selectBoard(id: boards[0].id)
              }
            } else {
              state.selectBoard(id: currentBoard)
            }
          } else {
            if (boards.count > 0) {
              state.selectBoard(id: boards[0].id)
            }
          }
        }
      }
      .frame(minWidth: 900, minHeight: 600, alignment: .top)
      .onReceive(timer) { newTime in
        if let boardVm {
          self.trelloApi.getBoard(id: boardVm.board.id) { board in
            if (board.id == boardVm.board.id) {
              boardVm.selectBoard(board: board)
            }
          }
       }
      }
      .sheet(isPresented: $showCommandBar) {
          VStack {
            CommandBarView()
          }
          .background(.black.opacity(0.8))
          .frame(minWidth: 400, minHeight: 600)
      }
    }
    .onChange(of: state.selectedBoard) { newBoard in
      if let selectedBoard = newBoard {
          boardVm = BoardState(api: state.api!, board: selectedBoard)
        
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(showCommandBar: .constant(true))
      .environmentObject(TrelloApi.testing)
  }
}
