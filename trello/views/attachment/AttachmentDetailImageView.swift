//
//  AttachmentDetailImageView.swift
//  trello
//
//  Created by Jan Christophersen on 11.11.22.
//

import SwiftUI
import AppKit
import CachedAsyncImage

struct AttachmentDetailImageView: View {
  @EnvironmentObject var trelloApi: TrelloApi
  @Binding var attachment: Attachment
  
  @State private var image: AnyView? = nil
  
  var body: some View {
    VStack {
      if let image = self.image {
        image
      } else {
        EmptyView()
      }
    }
    .task {
      if attachment.isUpload {
        self.trelloApi.downloadAttachment(url: attachment.url) { data in
          guard let nsImage = NSImage(data: data) else { return }
          self.image = AnyView(Image(nsImage: nsImage)
            .resizable()
            .scaledToFit())
        }
      } else {
        self.image = AnyView(CachedAsyncImage(url: URL(string: attachment.url)) { phase in
          switch phase {
          case .empty:
            ProgressView()
          case .success(let image):
            image.resizable()
              .scaledToFit()
          case .failure:
            EmptyView()
          @unknown default:
            EmptyView()
          }
        })
      }
    }
  }
}

struct AttachmentDetailImageView_Previews: PreviewProvider {
  static var previews: some View {
    AttachmentDetailImageView(attachment: .constant(Attachment(id: "id", bytes: 0, date: TrelloApi.DateFormatter.string(from: Date.now), edgeColor: "", idMember: "", isUpload: true, mimeType: "image/png", name: "image", pos: 0, previews: [Preview(id: "", scaled: false, url: "", bytes: 0, height: 64, width: 64)], url: "")))
  }
}
