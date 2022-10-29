//
//  SidebarView.swift
//  trello
//
//  Created by Jan Christophersen on 10.10.22.
//

import SwiftUI

struct SidebarView: View {
    @EnvironmentObject var trelloApi: TrelloApi;
    
    @State var hovering: Bool = false;
    @State var width: CGFloat = 32.0;
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if hovering {
                Text("Boards")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .padding(.leading, 4)
                Divider()
                    .frame(width: 200)
                ForEach(self.$trelloApi.boards) { board in
                    SidebarBoardView(board: board, currentBoard: self.$trelloApi.board)
                }
                Spacer()
            } else {
                Image(systemName: "books.vertical.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .padding(.leading, 4)
                Spacer()
            }
        }
        .onHover { hover in
            self.hovering = hover
            
            withAnimation(.easeInOut(duration: 0.1)) {
                self.width = self.hovering ? 200 : 32
            }
        }
        .frame(alignment: .top)
        .frame(minWidth: self.width, maxWidth: self.width)
        .padding(8)
        .background(Color("TwZinc900"))
    }
}

struct SidebarView_Previews: PreviewProvider {
    static var previews: some View {
        SidebarView()
    }
}
