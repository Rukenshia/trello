//
//  RightSidebarView.swift
//  trello
//
//  Created by Jan Christophersen on 27.10.22.
//

import SwiftUI

struct RightSidebarView: View {
  @EnvironmentObject var state: AppState
  @EnvironmentObject var trelloApi: TrelloApi
  @EnvironmentObject var boardVm: BoardState
  
  @State private var showDoneList: Bool = false
  @State private var showCreateMenu: Bool = false
  @State private var showErrors: Bool = false
  @State private var showManageLabels: Bool = false
  @State private var showMembers: Bool = false
  
  @State private var archivedCards: [Card] = []
  @State private var boardActions: [ActionUpdateCard] = []
  
  var doneList: List? {
    boardVm.board.lists.first(where: { l in l.name.starts(with: "✔️") })
  }
  
  var body: some View {
    HStack {
      VStack {
        Button(action: {
          self.showCreateMenu = true
        }) { }
          .buttonStyle(IconButton(icon: "plus"))
          .popover(isPresented: self.$showCreateMenu, attachmentAnchor: .point(.bottom), arrowEdge: .bottom) {
            VStack {
              Button("List", action: {
                boardVm.createList(name: "New list")
              })
              .buttonStyle(.plain)
              .font(.title3)
            }
            .padding(16)
          }
        
        Button(action: {
          self.showManageLabels = true
        }) { }
          .buttonStyle(IconButton(icon: "tag"))
          .sheet(isPresented: self.$showManageLabels) {
            ManageBoardLabelsView(labels: boardVm.board.labels)
          }
        
        if let dl = doneList {
          Button(action: {
            self.showDoneList = true
          }) { }
            .buttonStyle(IconButton(icon: "checkmark.circle.fill"))
            .sheet(isPresented: self.$showDoneList) {
              TabView {
                DoneListView(boardActions: boardActions, cards: dl.cards, list: dl)
                  .tabItem {
                    SwiftUI.Label("Done List", systemImage: "checkmark")
                  }
                DoneListView(boardActions: boardActions, cards: archivedCards, list: nil)
                  .frame(minWidth: 300, maxWidth: 300)
                  .tabItem {
                    SwiftUI.Label("Archive", systemImage: "archivebox")
                  }
              }
              .frame(minWidth: 400, minHeight: 600)
            }
            .task {
              trelloApi.getBoardUpdateCardActions(boardId: boardVm.board.id) { actions in
                boardActions = actions
              }
            }
        }
        
        Button(action: {
          self.showMembers = true
        }) {
          
        }
        .buttonStyle(
          IconButton(icon: "person")
        )
        .symbolRenderingMode(.hierarchical)
        .popover(isPresented: self.$showMembers, arrowEdge: .bottom) {
          MembersView(members: boardVm.board.members)
        }
        
        Spacer()
        
        Button(action: {
          self.showErrors = true
        }) {
          
        }
        .buttonStyle(
          IconButton(icon: "exclamationmark.triangle", iconColor: self.trelloApi.errors > 0 ? .red : .secondary)
        )
        .symbolRenderingMode(.hierarchical)
        .popover(isPresented: self.$showErrors, arrowEdge: .top) {
          VStack {
            Text("\(self.trelloApi.errors) api errors during current session, check if you have the app open multiple times")
            Divider()
            ForEach(self.trelloApi.errorMessages, id: \.self) { message in
              Text(message)
            }
          }.padding()
        }
      }
    }
    .task {
      trelloApi.getBoardCards(id: boardVm.board.id, filter: "closed", limit: 50) { cards in
        self.archivedCards = cards
      }
    }
    .padding(8)
  }
}

struct RightSidebarView_Previews: PreviewProvider {
  static var previews: some View {
    RightSidebarView(board: Board(id: "board", idOrganization: "id", name: "board", prefs: BoardPrefs(), boardStars: []))
      .environmentObject(TrelloApi.testing)
  }
}
