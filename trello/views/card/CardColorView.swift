//
//  CardColorView.swift
//  trello
//
//  Created by Jan Christophersen on 14.10.22.
//

import SwiftUI

struct CardColorView: View {
    @EnvironmentObject var trelloApi: TrelloApi
    @Binding var card: Card
    var colorName: CardCoverColor
    let apply: (CardCoverColor) -> Void
    @Binding var show: Bool
    
    @State var color: AnyView = AnyView(Color(.clear))
    
    var body: some View {
        Button(action: {
            self.apply(colorName)
        }) {
            Text("click me pretty please")
                .foregroundColor(.clear)
                .frame(width: 64, height: 48)
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle()) // TODO: cannot click entire button
        .background(self.color)
        .cornerRadius(4)
        .onHover { hover in
            if hover {
                self.color = AnyView(self.color.brightness(0.1))
            } else {
                self.color = AnyView(CardCover(color: self.colorName, size: .full, brightness: .dark).displayColor);
            }
        }
        .onAppear {
            self.color = AnyView(CardCover(color: self.colorName, size: .full, brightness: .dark).displayColor);
        }
    }
}

struct CardColorView_Previews: PreviewProvider {
    static var previews: some View {
        CardColorView(card: .constant(Card(id: "card-id", name: "card-name")), colorName: .red, apply: {_ in }, show: .constant(true))
    }
}
