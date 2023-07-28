//
//  BoardListsView.swift
//  trello
//
//  Created by Jan Christophersen on 28.07.23.
//

import SwiftUI

struct BoardListsView: View {
  @EnvironmentObject var boardVm: BoardState
  @EnvironmentObject var trelloApi: TrelloApi

  
  @Binding var board: Board
  @Binding var viewType: BoardViewType
  
  @State private var preferences = Preferences()
  @State private var scale: CGFloat = 1.0
  
  var body: some View {
    ScrollView([.horizontal]) {
      VStack(alignment: .leading) {
        HStack(alignment: .top) {
          ForEach($boardVm.board.lists.filter{ list in !list.wrappedValue.name.contains("✔️")}) { list in
            TrelloListView(list: list, scale: $scale)
          }
        }
      }
      .padding()
      Spacer()
    }
    .toolbar {
      
      ToolbarItem(placement: .navigation) {
        Button() {
          if boardVm.board.boardStars.isEmpty {
            trelloApi.createMemberBoardStar(boardId: boardVm.board.id) { boardStar in
              boardVm.board.boardStars = [boardStar]
            }
          } else {
            trelloApi.deleteMemberBoardStar(boardStarId: boardVm.board.boardStars[0].id ?? boardVm.board.boardStars[0]._id!) {
              boardVm.board.boardStars = []
            }
          }
        } label: {
          Image(systemName: !boardVm.board.boardStars.isEmpty ? "star.fill" : "star")
            .foregroundColor(!boardVm.board.boardStars.isEmpty ? .yellow : .secondary )
        }
      }
      
      ToolbarItemGroup(placement: .primaryAction) {
        Button(action: { setScale(scale + 0.1) }) {
          Image(systemName: "plus.magnifyingglass")
        }
        Button(action: { setScale(1.0) }) {
          Text("\(Int(scale * 100))%")
        }
        Button(action: { setScale(scale - 0.1) }) {
          Image(systemName: "minus.magnifyingglass")
        }
        
        // FIXME: could not get the order on the toolbar correctly, that is why this is not in BoardView
        ToolbarBoardVisualisationView(viewType: $viewType)
      }
      
    }
    .onAppear {
      
      scale = preferences.scale;
    }
  }
  
  private func setScale(_ newScale: CGFloat) {
    scale = newScale;
    
    
    if (scale < 0.3) {
      scale = 0.3
    }
    
    if (scale > 2) {
      scale = 2
    }
    
    preferences.scale = scale;
    preferences.save();
  }
}
