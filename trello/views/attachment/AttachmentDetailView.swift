//
//  AttachmentDetailView.swift
//  trello
//
//  Created by Jan Christophersen on 26.11.22.
//

import SwiftUI

struct AttachmentDetailView: View {
  @Environment(\.openWindow) var openWindow
  
  @Binding var attachment: Attachment
  let onDelete: () -> Void
  
  var body: some View {
    Button(action: {
      openWindow(value: attachment)
    }) {
      VStack(alignment: .leading) {
        if let mimeType = attachment.mimeType {
          switch(mimeType) {
          case "image/png", "image/jpeg":
            AttachmentDetailImageView(attachment: $attachment)
          default:
            EmptyView()
          }
        } else {
          if attachment.url.hasSuffix(".png") || attachment.url.hasSuffix(".jpg") {
            AttachmentDetailImageView(attachment: $attachment)
              .frame(width: 500, height: 500)
          } else {
            EmptyView()
          }
        }
        
        Text(attachment.name)
          .font(.title2)
        Text(attachment.url)
          .font(.subheadline)
          .foregroundColor(.secondary)
        
        Spacer()
      }
    }
    .buttonStyle(.plain)
  }
}

struct AttachmentDetailView_Previews: PreviewProvider {
  static var previews: some View {
    AttachmentDetailView(attachment: .constant(Attachment(id: "id", bytes: 0, date: TrelloApi.DateFormatter.string(from: Date.now), edgeColor: "", idMember: "", isUpload: false, mimeType: "image/png", name: "image", pos: 0, previews: [Preview(id: "", scaled: false, url: "", bytes: 0, height: 64, width: 64)], url: "https://via.placeholder.com/500")), onDelete: { })
      .environmentObject(TrelloApi.testing)
  }
}
