//
//  BoardView.swift
//  trello
//
//  Created by Jan Christophersen on 28.10.22.
//

import SwiftUI

struct BoardView: View {
  @EnvironmentObject var trelloApi: TrelloApi
  @Binding var board: Board
  @Binding var viewType: BoardViewType
  
  @State private var organization: Organization?
  
  var backgroundImage: AnyView {
    guard let url = trelloApi.board.prefs.backgroundImage else {
      return AnyView(Image("DefaultBoardBackground")
        .resizable()
        .aspectRatio(contentMode: .fill))
    }
    
    // TODO: the old background image stays around until the new one is loaded, maybe there's a way
    //       to force the placeholder in the meantime?
    return AnyView(AsyncImage(url: URL(string: url)) { phase in
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
        GeometryReader { reader in
          ScrollView([.horizontal]) {
            VStack {
              HStack(alignment: .top) {
                ForEach(self.$board.lists.filter{ list in !list.wrappedValue.name.contains("✔️")}) { list in
                  TrelloListView(list: list, windowHeight: reader.size.height)
                    .fixedSize(horizontal: false, vertical: true)
                }
              }
            }
            .frame(alignment: .top)
            .padding()
            Spacer()
          }
          .background(
            self.backgroundImage.allowsHitTesting(false)
          )
          .clipped()
        }
        .navigationTitle(board.name)
        .navigationSubtitle(organization?.displayName ?? "")
      case .table:
        BoardTableView(board: $board)
          .background(
            self.backgroundImage.allowsHitTesting(false).opacity(0.05)
          )
          .clipped()
          .navigationTitle(board.name)
          .navigationSubtitle(organization?.displayName ?? "")
      }
    }
    .onChange(of: board) { board in
        self.trelloApi.getOrganization(id: board.idOrganization) { organization in
          self.organization = organization
        }
      }
  }
}

struct BoardView_Previews: PreviewProvider {
  static var previews: some View {
    BoardView(board: .constant(Board(id: "id", idOrganization: "orgId", name: "board", prefs: BoardPrefs())), viewType: .constant(.table))
  }
}
