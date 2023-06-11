//
//  OrganizationView.swift
//  trello
//
//  Created by Jan Christophersen on 12.11.22.
//

import SwiftUI
import Alamofire
import CachedAsyncImage

struct OrganizationView: View {
  @EnvironmentObject var preferences: Preferences
  
  let organization: Organization
  let stars: [BoardStar]
  
  @State private var image: AnyView? = nil
  @State private var expanded = true
  
  var defaultLogo: some View {
    Rectangle()
      .fill(
        LinearGradient(gradient: Gradient(colors: [Color(red: 253 / 255, green: 230 / 255, blue: 138 / 255),
                                                   Color(red: 245 / 255, green: 158 / 255, blue: 11 / 255)]), startPoint: .topLeading, endPoint: .bottomTrailing)
      )
      .frame(width: 32, height: 32)
      .cornerRadius(4)
      .overlay {
        Text(String(organization.name.first!).uppercased())
          .foregroundColor(.white)
          .font(.system(size: 24))
      }
  }
  
  var body: some View {
    VStack(alignment: .leading) {
      
      DisclosureGroup(isExpanded: $expanded) {
        ForEach(organization.boards.sorted(by: { a, b in
          let starredA = stars.first(where: { s in s.idBoard == a.id})
          let starredB = stars.first(where: { s in s.idBoard == b.id})
          
          if let starA = starredA {
            if let starB = starredB {
              return starA.pos < starB.pos
            } else {
              return true
            }
          }
          
          if starredB != nil {
            return false
          }
          
          return a.name > b.name
          
        })) { board in
          SidebarBoardView(board: board, starred: stars.first(where: { s in s.idBoard == board.id}) != nil)
        }
        .padding(.leading, 12)
      } label: {
        HStack {
          if let image = self.image {
            image
          } else {
            defaultLogo
          }
          
          Text(organization.displayName)
            .font(.title2)
            .lineLimit(1)
        }
        .padding(.leading, 4)
        .padding(.bottom, 4)
        .onTapGesture {
          withAnimation {
            expanded.toggle()
          }
        }
      }
    }
    .task {
      if let logoUrl = organization.logoUrl {
        self.image = AnyView(CachedAsyncImage(url: URL(string: "\(logoUrl)/50.png"), urlCache: .imageCache) { phase in
          switch phase {
          case .empty:
            defaultLogo
          case .success(let image):
            image.resizable()
              .frame(width: 32, height: 32)
          case .failure:
            defaultLogo
          @unknown default:
            EmptyView()
          }
        })
      }
    }
    .onAppear {
      if preferences.organizations[organization.id] == nil {
        preferences.organizations[organization.id] = OrganizationPreferences(collapsed: false)
      }
      
      expanded = !(preferences.organizations[organization.id]?.collapsed ?? false)
    }
    .onChange(of: expanded) { value in
      preferences.organizations[organization.id] = OrganizationPreferences(collapsed: !value)
      preferences.save()
    }
  }
}

struct OrganizationView_Previews: PreviewProvider {
  static var previews: some View {
    OrganizationView(organization: Organization(id: "", name: "", displayName: "", logoUrl: ""), stars: [])
  }
}
