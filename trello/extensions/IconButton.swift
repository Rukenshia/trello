//
//  IconButton.swift
//  trello
//
//  Created by Jan Christophersen on 27.10.22.
//

import SwiftUI

struct IconButton: ButtonStyle {
    var icon: String
    var iconColor: Color = .primary
    var size: CGFloat = 24
    var color: Color = Color("ButtonBackground").opacity(0.8)
    var hoverColor: Color = Color("ButtonBackground")
    var padding: CGFloat = 4.0
    
    @State var hovering: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        Image(systemName: self.icon)
            .font(.system(size: self.size))
            .padding(self.padding)
            .background(self.hovering ? self.hoverColor : self.color)
            .foregroundColor(self.iconColor)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
            .onHover { hover in
                self.hovering = hover
            }
    }
}
