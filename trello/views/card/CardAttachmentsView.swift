//
//  CardAttachmentsView.swift
//  trello
//
//  Created by Jan Christophersen on 11.11.22.
//

import SwiftUI

struct CardAttachmentsView: View {
  @EnvironmentObject var trelloApi: TrelloApi
  
  @Binding var card: Card
  
  @State private var attachments: [Attachment] = []
  
  var body: some View {
    VStack {
      ForEach(self.attachments) { attachment in
        AttachmentView(attachment: attachment, onDelete: {
          trelloApi.deleteCardAttachment(cardId: card.id, attachmentId: attachment.id) {
            attachments.removeAll(where: { a in a.id == attachment.id })
          }
        })
      }
    }
    .task {
      self.trelloApi.getCardAttachments(id: card.id) { attachments in
        self.attachments = attachments
      }
    }
  }
}

struct CardAttachmentsView_Previews: PreviewProvider {
  static var previews: some View {
    CardAttachmentsView(card: .constant(Card(id: "id", name: "name")))
  }
}
