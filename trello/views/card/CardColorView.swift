//
//  CardColorView.swift
//  trello
//
//  Created by Jan Christophersen on 14.10.22.
//

import SwiftUI

struct CardColorView: View {
  @EnvironmentObject var trelloApi: TrelloApi
  let card: Card
  var colorName: CardCoverColor
  let apply: (CardCoverColor) -> Void
  
  @State private var hovering = false
  
  
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
    .background(
      CardCover(color: self.colorName, size: .full, brightness: .dark).displayColor
        .brightness(hovering ? 0.1 : 0.0)
    )
    .cornerRadius(8)
    .onHover { hover in
      hovering = hover
    }
  }
}

struct CardColorView_Previews: PreviewProvider {
  static var previews: some View {
    CardColorView(card: Card(id: "card-id", name: "card-name"), colorName: .red, apply: {_ in })
  }
}
