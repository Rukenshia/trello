//
//  SidebarView.swift
//  trello
//
//  Created by Jan Christophersen on 10.10.22.
//

import SwiftUI

struct SidebarView: View {
  @EnvironmentObject var preferences: Preferences
  @EnvironmentObject var trelloApi: TrelloApi
  
  @State var organizations: [Organization] = []
  @State private var stars: [BoardStar] = []
  @State private var expandFavorites = true
  
  private var starredBoards: [BasicBoard] {
    stars.map { star in
      var board: BasicBoard? = nil
      
      for organization in organizations {
        if let b = organization.boards.first(where: { b in b.id == star.idBoard }) {
          board = b
          break
        }
      }
      
      return board
    }
    .filter{ b in b != nil }
    .map{ b in b! }
  }
  
  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      if !starredBoards.isEmpty {
        DisclosureGroup(isExpanded: $expandFavorites) {
          Divider()
          
          ScrollView {
            ForEach(starredBoards) { board in
              SidebarBoardView(board: board, starred: true)
            }
          }
          .frame(height: min(CGFloat(starredBoards.count) * 32.0, 160))
        } label: {
          HStack {
            Text("Favorites")
              .font(.system(size: 18))
              .multilineTextAlignment(.leading)
              .padding(.leading, 4)
          }
        }
      }
      
      HStack {
        Text("Boards")
          .font(.system(size: 18))
          .multilineTextAlignment(.leading)
          .padding(.leading, 4)
      }
      Divider()
      
      ScrollView {
        ForEach(organizations) { organization in
          OrganizationView(organization: organization, stars: stars)
        }
      }
    }
    .frame(alignment: .top)
    .padding(8)
    .onAppear {
      expandFavorites = preferences.showFavorites
    }
    .onChange(of: self.expandFavorites) { value in
      preferences.updateShowFavorites(value)
    }
    .onChange(of: trelloApi.board.boardStars) { _ in
      trelloApi.getMemberBoardStars { stars in
        self.stars = stars
      }
    }
    .task {
      trelloApi.getMemberBoardStars { stars in
        self.stars = stars
      }
      
      trelloApi.getOrganizations() { organizations in
        self.organizations = []
        
        for organization in organizations {
          var organization = organization
          trelloApi.getOrganizationBoards(id: organization.id) { boards in
            organization.boards = boards
            
            self.organizations.append(organization)
          }
        }
      }
    }
  }
  
  struct SidebarView_Previews: PreviewProvider {
    static var previews: some View {
      SidebarView()
        .environmentObject(TrelloApi.testing)
    }
  }
}
