//
//  RightSidebarView.swift
//  trello
//
//  Created by Jan Christophersen on 27.10.22.
//

import SwiftUI

struct RightSidebarView: View {
    @EnvironmentObject var trelloApi: TrelloApi
    var doneList: Binding<List>?;
    
    @State private var showDoneList: Bool = false
    @State private var showCreateMenu: Bool = false
    @State private var showErrors: Bool = false
    
    init(doneList: Binding<List>? = nil) {
        self.doneList = doneList
    }
    
    var body: some View {
        HStack {
            VStack {
                Button(action: {
                    self.showCreateMenu = true
                }) { }
                    .buttonStyle(IconButton(icon: "plus"))
                    .popover(isPresented: self.$showCreateMenu, attachmentAnchor: .point(.bottom), arrowEdge: .bottom) {
                        VStack {
                            Button("List", action: {
                                self.trelloApi.createList(boardId: self.trelloApi.board.id, name: "New list") { _ in
                                    
                                }
                            })
                            .buttonStyle(.plain)
                            .font(.title3)
                        }
                        .padding(16)
                    }
                
                if let dl = doneList {
                    Button(action: {
                        self.showDoneList = true
                    }) { }
                        .buttonStyle(IconButton(icon: "checkmark.circle.fill"))
                        .popover(isPresented: self.$showDoneList, attachmentAnchor: .point(.bottom), arrowEdge: .bottom) {
                            DoneListView(list: dl)
                                .frame(minWidth: 300, maxWidth: 300)
                                .background(Color("TwZinc900")
                                    .scaleEffect(1.5))
                        }
                }
                Spacer()
                
                Button(action: {
                    self.showErrors = true
                }) {
                    
                }
                .buttonStyle(
                    IconButton(icon: "exclamationmark.triangle", iconColor: self.trelloApi.errors > 0 ? .red : .secondary)
                )
                .symbolRenderingMode(.hierarchical)
                .popover(isPresented: self.$showErrors, arrowEdge: .top) {
                    VStack {
                        Text("\(self.trelloApi.errors) api errors during current session, check if you have the app open multiple times")
                        Divider()
                        ForEach(self.trelloApi.errorMessages, id: \.self) { message in
                            Text(message)
                        }
                    }.padding()
                }
            }
        }.padding(8)
    }
}

struct RightSidebarView_Previews: PreviewProvider {
    static var previews: some View {
        RightSidebarView(doneList: nil)
            .environmentObject(TrelloApi(key: "", token: ""))
    }
}
