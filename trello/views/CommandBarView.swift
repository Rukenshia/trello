//
//  CommandBarView.swift
//  trello
//
//  Created by Jan Christophersen on 02.01.23.
//

import SwiftUI

import SwiftUI

struct CommandBarProviderView: View {
  @Binding var boards: [BasicBoard]
  
  var body: some View {
    ForEach($boards.indices, id: \.self) { board in
      Text(boards[board].name)
    }
  }
}

struct CommandBarView: View {
  @EnvironmentObject var trelloApi: TrelloApi
  
  @State private var search: String = ""
  @State var selection: Int?
  
  var body: some View {
    VStack {
      HStack {
        VStack {
          ZStack {
            TextField("", text: $search)
              .font(.largeTitle)
              .textFieldStyle(.plain)
              .padding(4)
              .padding(.horizontal, 6)
              .padding(.leading, 28)
            
            HStack {
              Image(systemName: "command")
                .padding(.leading, 4)
                .font(.system(size: 24))
                .foregroundColor(.secondary)
              Spacer()
            }
          }
          .padding(.horizontal, 4)
          .padding(.top, 4)
          .frame(minWidth: 200)
          
          Divider()
          
          SwiftUI.List(selection: $selection) {
            Section(header: Text("Switch to board")) {
              CommandBarProviderView(boards: $trelloApi.boards)
            }
            .listStyle(.plain)
          }
          .padding(4)
        }
        .background(Color("CardBackground").brightness(-0.05))
        .cornerRadius(8)
      }
    }
    .onAppear {
      NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { nsevent in
        if selection != nil {
          if nsevent.keyCode == 125 { // arrow down
            selection = selection! < 10 ? selection! + 1 : 0
          } else {
            if nsevent.keyCode == 126 { // arrow up
              selection = selection! > 1 ? selection! - 1 : 0
            }
          }
        } else {
          selection = 0
        }
        return nsevent
      }
    }
    .frame(minHeight: 32)
    .frame(minWidth: 600, maxWidth: .infinity)
  }
}

struct CommandBarView_Previews: PreviewProvider {
  static var previews: some View {
    CommandBarView()
    //    CommandBarProviderView(boards: .constant([BasicBoard(id: "id", name: "name", prefs: BoardPrefs())]))
  }
}
