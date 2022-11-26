//
//  AttachmentView.swift
//  trello
//
//  Created by Jan Christophersen on 11.11.22.
//

import SwiftUI

struct AttachmentView: View {
  @Binding var attachment: Attachment
  let onDelete: () -> Void
  
  var body: some View {
    HStack {
      VStack {
        if let mimeType = attachment.mimeType {
          switch(mimeType) {
          case "image/png", "image/jpeg":
            AttachmentImageView(attachment: $attachment)
              .frame(width: 64, height: 64)
          default:
            EmptyView()
          }
        } else {
          if attachment.url.hasSuffix(".png") || attachment.url.hasSuffix(".jpg") {
            AttachmentImageView(attachment: $attachment)
              .frame(width: 64, height: 64)
          } else {
            EmptyView()
          }
        }
      }
      .background(Color("ButtonBackground").brightness(-0.1))
      .cornerRadius(4)
      .frame(width: 64, height: 64)
      .padding()
      .padding(.horizontal, 4)
      
      VStack(alignment: .leading) {
        HStack {
          Text(attachment.name)
            .font(.title2)
          
          Spacer()
          
          Button(action: onDelete) { }
            .buttonStyle(IconButton(icon: "trash", size: 12))
        }
        Text(attachment.url)
          .font(.subheadline)
          .foregroundColor(.secondary)
      }
      
      Spacer()
    }
    .background(Color("ButtonBackground"))
    .cornerRadius(4)
  }
}

struct AttachmentView_Previews: PreviewProvider {
  static var previews: some View {
    AttachmentView(attachment: .constant(Attachment(id: "id", bytes: 0, date: TrelloApi.DateFormatter.string(from: Date.now), edgeColor: "", idMember: "", isUpload: true, mimeType: "image/png", name: "image", pos: 0, previews: [Preview(id: "", scaled: false, url: "", bytes: 0, height: 64, width: 64)], url: "")), onDelete: { })
  }
}
