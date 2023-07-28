//
//  CardAttachmentDropView.swift
//  trello
//
//  Created by Jan Christophersen on 28.07.23.
//

import SwiftUI

struct CardAttachmentDropView: View {
  @EnvironmentObject var trelloApi: TrelloApi
  
  let cardId: String
  let onCreate: (Attachment) -> Void
  
  @State private var isDropping = false
  
  var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 4)
        .strokeBorder(Color.gray, lineWidth: 1)
        .background(isDropping ? Color.gray.opacity(0.2) : Color.clear)
      HStack {
        Spacer()
        VStack {
          Image(systemName: "plus")
            .font(.system(size: 30))
            .foregroundColor(.gray)
          Text("Attach a file by dropping it here")
            .font(.system(size: 12))
            .foregroundColor(.gray)
        }
        Spacer()
      }
    }
    .onDrop(of: [.fileURL], delegate: CardAttachmentDropDelegate(trelloApi: trelloApi, cardId: cardId, dropping: $isDropping, onCreate: onCreate))
  }
}

struct CardAttachmentDropView_Previews: PreviewProvider {
  static var previews: some View {
    CardAttachmentDropView(cardId: "", onCreate: { _ in })
  }
}

