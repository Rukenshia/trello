//
//  ContextMenuCardColorView.swift
//  trello
//
//  Created by Jan Christophersen on 09.10.22.
//

import SwiftUI

struct ContextMenuCardColorView: View {
  @EnvironmentObject var boardVm: BoardState
  let card: Card;
  
  @State var size: CardCoverSize = .full
  
  var body: some View {
    VStack(alignment: .leading) {
      Text("Size")
        .font(.title3)
      CardCoverSizeView(size: self.$size)
      
      Text("Color")
        .font(.title3)
      LazyVGrid(columns: [GridItem(.flexible(minimum: 64)), GridItem(.flexible(minimum: 64)), GridItem(.flexible(minimum: 64))], spacing: 8) {
        ForEach(CardCoverColor.allCases, id: \.self) { colorName in
          CardColorView(card: card, colorName: colorName,
                        apply: self.updateCover)
        }
        Button(action: {
          self.removeCover()
        }) {
          VStack {
            Spacer()
            HStack {
              Image(systemName: "slash.circle")
                .font(.system(size: 24))
                .foregroundColor(Color("TwZinc300"))
                .symbolRenderingMode(.hierarchical)
            }
            Spacer()
          }
          .frame(width: 64, height: 48)
          .border(Color("TwZinc300"), width: 2)
          .cornerRadius(4)
        }
        .buttonStyle(.plain)
      }
    }
    .padding(16)
    .padding(.vertical, 24)
    .onChange(of: size) { newSize in
      if card.cover?.color != nil {
        self.updateCover(card.cover!.color)
      }
    }
    .onAppear {
      if let cover = card.cover {
        self.size = cover.size
      }
    }
  }
  
  private func updateCover(_ color: CardCoverColor?) {
    boardVm.updateCard(cardId: self.card.id, cover: CardCover(color: color, size: self.size, brightness: .dark))
  }
  
  private func removeCover() {
    boardVm.removeCardCover(cardId: self.card.id)
  }
}

struct ContextMenuCardColorView_Previews: PreviewProvider {
  static var previews: some View {
    ContextMenuCardColorView(card: Card(id: "cardid", name: "card"))
  }
}
