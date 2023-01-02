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
  @EnvironmentObject var trelloApi: TrelloApi
  
  @Binding var organization: Organization
  
  @State private var image: AnyView? = nil
  
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
      
      ForEach($organization.boards) { board in
        SidebarBoardView(board: board, currentBoard: self.$trelloApi.board)
      }
    }
    .task {
      if let logoUrl = organization.logoUrl {
        self.image = AnyView(CachedAsyncImage(url: URL(string: "\(logoUrl)/50.png")) { phase in
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
  }
}

struct OrganizationView_Previews: PreviewProvider {
  static var previews: some View {
    OrganizationView(organization: .constant(Organization(id: "", name: "", displayName: "", logoUrl: "")))
  }
}
