//
//  FlatButton.swift
//  trello
//
//  Created by Jan Christophersen on 29.10.22.
//

import SwiftUI

struct FlatButton: ButtonStyle {
    var icon: String?
    var text: String?
    
    @State var color: Color = Color("TwZinc700").opacity(0.8)
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            if let icon = self.icon {
                Image(systemName: icon)
            }
            if let text = self.text {
                Text(text)
            }
            configuration.label
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(self.color)
        .cornerRadius(4)
        .onHover { hover in
            withAnimation(.easeInOut(duration: 0.1)) {
                self.color = hover ? Color("TwZinc700") : Color("TwZinc700").opacity(0.8);
                
                if (hover) {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }
        }
    }
}

