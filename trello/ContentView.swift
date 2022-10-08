//
//  ContentView.swift
//  trello
//
//  Created by Jan Christophersen on 24.09.22.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var trelloApi: TrelloApi;
    
    var backgroundImage: some View {
        var url = "https://trello-backgrounds.s3.amazonaws.com/54d4b4fc032569bd9870ac0a/original/04b4f28b09473079050638ab87426857/chrome_theme_bg_explorer.jpg";

        if trelloApi.board.prefs.backgroundImage != nil {
            url = trelloApi.board.prefs.backgroundImage!
        }
        
        return AsyncImage(url: URL(string: url)) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case .success(let image):
                image.resizable()
                    .aspectRatio(contentMode: .fill)
            case .failure:
                Image(systemName: "photo")
            @unknown default:
                // Since the AsyncImagePhase enum isn't frozen,
                // we need to add this currently unused fallback
                // to handle any new cases that might be added
                // in the future:
                EmptyView()
            }
        }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 12) {
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
            }
            .frame(alignment: .top)
            .frame(minWidth: 200, maxWidth: 200)
            .padding(8)
            VStack {
                ScrollView([.horizontal]) {
                    ScrollView([.vertical]) {
                        VStack(){
                            HStack(alignment: .top) {
                                ForEach($trelloApi.board.lists) { list in
                                    TrelloListView(list: list, listIdx: 0)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                            .padding()
                            .frame(maxHeight: .infinity, alignment: .top)
                        }
                    }
                }
            }
            .background(self.backgroundImage)
        }.onAppear {
            trelloApi.getBoards { boards in
                if (boards.count > 0) {
                    trelloApi.getBoard(id: boards[0].id)
                }
            }
        }
        .frame(minWidth: 1600, minHeight: 600, alignment: .top)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(TrelloApi(key: "***REMOVED***", token: "***REMOVED***"))
    }
}
