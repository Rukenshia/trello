//
//  ContentView.swift
//  trello
//
//  Created by Jan Christophersen on 24.09.22.
//

import SwiftUI
import Combine

struct ContentView: View {
    @EnvironmentObject var trelloApi: TrelloApi;
    
    @State private var cancellable: AnyCancellable?;
    
    private var timer = Timer.publish(
        every: 5, // second
        on: .main,
        in: .common
    ).autoconnect();
    
    var backgroundImage: some View {
        var url = "https://trello-backgrounds.s3.amazonaws.com/54d4b4fc032569bd9870ac0a/original/04b4f28b09473079050638ab87426857/chrome_theme_bg_explorer.jpg";

        if trelloApi.board.prefs.backgroundImage != nil {
            url = trelloApi.board.prefs.backgroundImage!
        }
        
        // TODO: the old background image stays around until the new one is loaded, maybe there's a way
        //       to force the placeholder in the meantime?
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
                EmptyView()
            }
        }
    }
    
    var body: some View {
        HStack {
            SidebarView()
            VStack {
                ScrollView([.horizontal]) {
                    ScrollView([.vertical]) {
                        VStack(){
                            HStack(alignment: .top) {
                                ForEach($trelloApi.board.lists) { list in //.filter{ list in !list.name.wrappedValue.contains("✔️") }) { list in
                                    TrelloListView(list: list)
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
//            if let doneList = $trelloApi.board.lists.first(where: { list in list.name.wrappedValue.contains("✔️") }) {
//                TrelloListView(list: doneList)
//                    .fixedSize(horizontal: false, vertical: true)
//            }
        }.onAppear {
            self.cancellable = trelloApi.$board.sink { newBoard in
                if newBoard.id == "" {
                    return
                }
                
                UserDefaults.standard.set(newBoard.id, forKey: PreferenceKeys.currentBoard)
            }
            
            trelloApi.getBoards { boards in
                if let currentBoard = UserDefaults.standard.string(forKey: PreferenceKeys.currentBoard) {
                    print(currentBoard)
                    if currentBoard.isEmpty {
                        if (boards.count > 0) {
                            trelloApi.getBoard(id: boards[0].id)
                        }
                    } else {
                        print(currentBoard)
                        trelloApi.getBoard(id: currentBoard)
                    }
                } else {
                    if (boards.count > 0) {
                        trelloApi.getBoard(id: boards[0].id)
                    }
                }
            }
        }
        .frame(minWidth: 900, minHeight: 600, alignment: .top)
        .onReceive(timer) { newTime in
            self.trelloApi.getBoard(id: self.trelloApi.board.id) { board in
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(TrelloApi(key: Preferences().trelloKey!, token: Preferences().trelloToken!))
    }
}
