//
//  IconButton.swift
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
