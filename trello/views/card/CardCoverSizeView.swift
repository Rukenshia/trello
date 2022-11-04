//
//  CardCoverSizeView.swift
//  trello
//
//  Created by Jan Christophersen on 03.11.22.
//

import SwiftUI

struct CardCoverSizeView: View {
    @Binding var size: CardCoverSize
    
    var body: some View {
        HStack {
            Button(action: {
                self.size = .full
            }) {
                VStack {
                    Rectangle()
                        .fill(Color("TwZinc600"))
                        .frame(width: 96, height: 56)
                }
                .border(self.size == .full ? .blue : .clear, width: 2)
                .cornerRadius(4)
            }
            .buttonStyle(.plain)
            
            Button(action: {
                self.size = .normal
            }) {
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(Color("TwZinc600"))
                        .frame(width: 96, height: 24)
                    Rectangle()
                        .fill(Color("TwZinc700"))
                        .frame(width: 96, height: 32)
                }
                .border(self.size == .normal ? .blue : .clear, width: 2)
                .cornerRadius(4)
                .padding(4)
            }
            .buttonStyle(.plain)
        }
    }
}

struct CardCoverSizeView_Previews: PreviewProvider {
    static var previews: some View {
        CardCoverSizeView(size: .constant(.full))
    }
}
