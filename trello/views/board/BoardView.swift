//
//  BoardView.swift
//  trello
//
//  Created by Jan Christophersen on 28.10.22.
//

import SwiftUI
import CachedAsyncImage

struct BoardView: View {
  @EnvironmentObject var trelloApi: TrelloApi
  @EnvironmentObject var boardVm: BoardState
  
  @State private var viewType: BoardViewType = .lists
  
  @State private var organization: Organization?
  
  @State var preferences: Preferences = Preferences()
  @State private var scale: CGFloat = 1.0
  
  @ViewBuilder
  var backgroundImage: some View {
    if let url = boardVm.board.prefs.backgroundImage {
      CachedAsyncImage(url: URL(string: url), urlCache: .imageCache) { phase in
        switch phase {
        case .empty:
          ProgressView()
        case .success(let image):
          image.resizable()
            .aspectRatio(contentMode: .fill)
        case .failure:
          HStack {
            Image(systemName: "exclamationmark.triangle")
              .symbolRenderingMode(.hierarchical)
            
            Text("could not load background image")
          }
          .foregroundColor(.red)
          .font(.system(size: 24))
        @unknown default:
          EmptyView()
        }
      }
    } else {
      Image("DefaultBoardBackground")
        .resizable()
        .aspectRatio(contentMode: .fill)
    }
  }
  
  var body: some View {
    ZStack {
      switch viewType {
      case .lists:
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
        .background(
          self.backgroundImage.allowsHitTesting(false)
        )
        .clipped()
        .navigationTitle(boardVm.board.name)
        .navigationSubtitle(organization?.displayName ?? "")
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
            ToolbarBoardVisualisationView(viewType: $viewType)
          }
        }
      case .table:
        BoardTableView(board: $boardVm.board)
          .background(
            self.backgroundImage.allowsHitTesting(false).opacity(0.05)
          )
          .clipped()
          .navigationTitle(boardVm.board.name)
          .navigationSubtitle(organization?.displayName ?? "")
          .toolbar {
            ToolbarBoardVisualisationView(viewType: $viewType)
          }
      }
    }
    // TODO: needed?
    .onChange(of: boardVm.board.idOrganization) { newOrg in
      self.trelloApi.getOrganization(id: newOrg) { organization in
        self.organization = organization
      }
    }
    .onAppear {
      scale = preferences.scale;
      
      self.trelloApi.getOrganization(id: boardVm.board.idOrganization) { organization in
        self.organization = organization
      }
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

struct BoardView_Previews: PreviewProvider {
  static var previews: some View {
    BoardView()
      .environmentObject(TrelloApi.testing)
  }
}
