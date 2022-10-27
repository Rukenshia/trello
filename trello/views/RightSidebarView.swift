//
//  RightSidebarView.swift
//  trello
//
//  Created by Jan Christophersen on 27.10.22.
//

import SwiftUI

struct IconButton: ButtonStyle {
    var icon: String
    
    @State var hovering: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        Image(systemName: self.icon)
            .font(.system(size: 24))
            .padding(4)
            .background(self.hovering ? Color("CardBg") : Color("CardBg").opacity(0.8))
            .foregroundColor(.white)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
            .onHover { hover in
                self.hovering = hover
            }
    }
}

struct RightSidebarView: View {
    var doneList: Binding<List>?;
    
    @State var showDoneList: Bool = false
    
    var buttonCount: Int {
        var i = 0
        
        if doneList != nil {
            i += 1
        }
        
        return i
    }
    
    init(doneList: Binding<List>? = nil) {
        self.doneList = doneList
    }
    
    var body: some View {
        HStack {
            VStack {
                if let dl = doneList {
                Button(action: {
                    self.showDoneList = true
                }) { }
                .buttonStyle(IconButton(icon: "checkmark.circle.fill"))
                .popover(isPresented: self.$showDoneList) {
                    DoneListView(list: dl)
                        .frame(minWidth: 300, maxWidth: 300)
                }
                }
                Spacer()
            }
        }.padding(self.buttonCount > 0 ? 8 : 0)
    }
}

struct RightSidebarView_Previews: PreviewProvider {
    static var previews: some View {
        RightSidebarView(doneList: nil)
    }
}
