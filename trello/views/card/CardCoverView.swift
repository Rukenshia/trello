//
//  CardCoverView.swift
//  trello
//
//  Created by Jan Christophersen on 12.11.22.
//

import SwiftUI

struct CardCoverView: View {
  @EnvironmentObject var trelloApi: TrelloApi
  
  var cardId: String
  var cover: CardCover
  
  @State private var attachment: Attachment? = nil
  @State private var image: Image? = nil
  
    var body: some View {
      VStack {
        if cover.color != nil {
          if cover.size == .normal {
            HStack {
              Spacer()
            }
            .frame(height: 32)
            .background(cover.displayColor)
          }
        }
        
        if let image = self.image {
          HStack {
            if attachment?.mimeType == "image/gif" {
                image
            } else {
              image
                .resizable()
                .scaledToFill()
            }
          }
          .frame(maxWidth: .infinity)
        }
      }
      .task {
        if let idAttachment = cover.idAttachment {
          trelloApi.getCardAttachment(cardId: cardId, attachmentId: idAttachment) { attachment in
            self.attachment = attachment
            
            trelloApi.downloadAttachment(url: attachment.previews.last!.url, completion: { data in
              guard var nsImage = NSImage(data: data) else { return }
              self.image = Image(nsImage: nsImage)
            })
          }
        }
      }
    }
}

struct CardCoverView_Previews: PreviewProvider {
    static var previews: some View {
      CardCoverView(cardId: "", cover: CardCover(size: .normal, brightness: .light))
    }
}
