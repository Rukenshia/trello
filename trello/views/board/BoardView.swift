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
  
  @State private var showRightSidebar = false
  
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
        BoardListsView(board: $boardVm.board, viewType: $viewType)
          .navigationTitle(boardVm.board.name)
          .navigationSubtitle(organization?.displayName ?? "")
          .background(
            self.backgroundImage.allowsHitTesting(false)
          )
          .clipped()
      case .table:
        BoardTableView(board: $boardVm.board)
          .background(
            self.backgroundImage.allowsHitTesting(false).opacity(0.05)
          )
          .clipped()
          .navigationTitle(boardVm.board.name)
          .navigationSubtitle(organization?.displayName ?? "")
      }
    }
    // TODO: needed?
    .onChange(of: boardVm.board.idOrganization) { newOrg in
      self.trelloApi.getOrganization(id: newOrg) { organization in
        self.organization = organization
      }
    }
    .onAppear {
      
      self.trelloApi.getOrganization(id: boardVm.board.idOrganization) { organization in
        self.organization = organization
      }
    }
  }
}

struct BoardView_Previews: PreviewProvider {
  static var previews: some View {
    BoardView()
      .environmentObject(TrelloApi.testing)
  }
}
