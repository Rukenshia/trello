//
//  SidebarView.swift
//  trello
//
//  Created by Jan Christophersen on 10.10.22.
//

import SwiftUI

struct SidebarView: View {
  @EnvironmentObject var trelloApi: TrelloApi
  
  @State var organizations: [Organization] = []
  
  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      
      HStack {
        Text("Boards")
          .font(.system(size: 18))
          .multilineTextAlignment(.leading)
          .padding(.leading, 4)
      }
      Divider()
      
      ForEach($organizations) { organization in
        OrganizationView(organization: organization)
      }
      Spacer()
    }
    .frame(alignment: .top)
    .padding(8)
    .task {
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
        .environmentObject(TrelloApi(key: Preferences().trelloKey!, token: Preferences().trelloToken!))
    }
  }
}
