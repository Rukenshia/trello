//
//  AttachmentImageView.swift
//  trello
//
//  Created by Jan Christophersen on 11.11.22.
//

import SwiftUI
import AppKit

struct AttachmentImageView: View {
  @EnvironmentObject var trelloApi: TrelloApi
  @Binding var attachment: Attachment
  
  @State private var image: Image? = nil
  
  var body: some View {
    VStack {
      if let image = self.image {
        image
          .resizable()
          .scaledToFill()
      } else {
        EmptyView()
      }
    }
    .task {
      if attachment.isUpload {
        self.trelloApi.downloadAttachment(url: attachment.previews[5].url) { data in
          guard let nsImage = NSImage(data: data) else { return }
          self.image = Image(nsImage: nsImage)
        }
      }
    }
  }
}

struct AttachmentImageView_Previews: PreviewProvider {
  static var previews: some View {
    AttachmentImageView(attachment: .constant(Attachment(id: "id", bytes: 0, date: TrelloApi.DateFormatter.string(from: Date.now), edgeColor: "", idMember: "", isUpload: true, mimeType: "image/png", name: "image", pos: 0, previews: [Preview(id: "", scaled: false, url: "", bytes: 0, height: 64, width: 64)], url: "")))
  }
}
