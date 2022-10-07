//
//  ContentView.swift
//  trello
//
//  Created by Jan Christophersen on 24.09.22.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var trelloApi: TrelloApi;
    
    let timer = Timer.publish(
        every: 5, // second
        on: .main,
        in: .common
    ).autoconnect();
    
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
        VStack {
            ScrollView([.horizontal]) {
                ScrollView([.vertical]) {
                    VStack(){
                        HStack(alignment: .top) {
                            ForEach(trelloApi.lists) { list in
                                TrelloListView(list: list, listModel: ListViewModel(cards: list.cards))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .padding()
                        .frame(maxHeight: .infinity, alignment: .top)
                    }
                }
            }
            .frame(minWidth: 1600, minHeight: 600, alignment: .top)
        }
        .onReceive(self.timer) { newTime in
            trelloApi.getBoard(id: "5e491a01d252b36e22de0666", completion: { board in
                
                    trelloApi.objectWillChange.send()
            })
        }
        .onAppear {
            trelloApi.getBoard(id: "5e491a01d252b36e22de0666")
        }
        .background(self.backgroundImage)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(TrelloApi(key: "***REMOVED***", token: "***REMOVED***"))
    }
}
