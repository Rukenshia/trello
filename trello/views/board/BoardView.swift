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
  @Binding var board: Board
  
  @State private var viewType: BoardViewType = .lists
  
  @State private var organization: Organization?
  
  @State var preferences: Preferences = Preferences()
  @State private var scale: CGFloat = 1.0
  
  var backgroundImage: AnyView {
    guard let url = trelloApi.board.prefs.backgroundImage else {
      return AnyView(Image("DefaultBoardBackground")
        .resizable()
        .aspectRatio(contentMode: .fill))
    }
    
    // TODO: the old background image stays around until the new one is loaded, maybe there's a way
    //       to force the placeholder in the meantime?
    return AnyView(CachedAsyncImage(url: URL(string: url), urlCache: .imageCache) { phase in
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
    })
  }
  
  var body: some View {
    ZStack {
      switch viewType {
      case .lists:
        ScrollView([.horizontal]) {
          VStack(alignment: .leading) {
            HStack(alignment: .top) {
              ForEach(self.$board.lists.filter{ list in !list.wrappedValue.name.contains("✔️")}) { list in
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
        .navigationTitle(board.name)
        .navigationSubtitle(organization?.displayName ?? "")
        .toolbar {
          
          ToolbarItem(placement: .navigation) {
            Button() {
              if board.boardStars.isEmpty {
                trelloApi.createMemberBoardStar(boardId: board.id) { boardStar in
                  board.boardStars = [boardStar]
                }
              } else {
                trelloApi.deleteMemberBoardStar(boardStarId: board.boardStars[0].id ?? board.boardStars[0]._id!) {
                  board.boardStars = []
                }
              }
            } label: {
              Image(systemName: !board.boardStars.isEmpty ? "star.fill" : "star")
                .foregroundColor(!board.boardStars.isEmpty ? .yellow : .secondary )
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
        BoardTableView(board: $board)
          .background(
            self.backgroundImage.allowsHitTesting(false).opacity(0.05)
          )
          .clipped()
          .navigationTitle(board.name)
          .navigationSubtitle(organization?.displayName ?? "")
          .toolbar {
            ToolbarBoardVisualisationView(viewType: $viewType)
          }
      }
    }
    .onChange(of: board) { board in
      self.trelloApi.getOrganization(id: board.idOrganization) { organization in
        self.organization = organization
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

struct BoardView_Previews: PreviewProvider {
  static var previews: some View {
    BoardView(board: .constant(Board(id: "id", idOrganization: "orgId", name: "board", prefs: BoardPrefs(), boardStars: [], lists: [List(id: "foo", name: "foo"), List(id: "bar", name: "bar")])))
      .environmentObject(TrelloApi.testing)
  }
}
