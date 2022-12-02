//
//  AttachmentView.swift
//  trello
//
//  Created by Jan Christophersen on 11.11.22.
//

import SwiftUI
import Alamofire

struct AttachmentView: View {
  @Environment(\.openWindow) var openWindow
  @Environment(\.openURL) var openURL
  
  @EnvironmentObject var trelloApi: TrelloApi
  @Binding var attachment: Attachment
  let onDelete: () -> Void
  
  var isUrl: Bool {
    attachment.previews.count == 0 && attachment.mimeType == "" && !attachment.isUpload
  }
  
  var body: some View {
    Button(action: {
      if attachment.isUpload && ((attachment.mimeType?.hasPrefix("application/")) != nil) {
        
        let destination: DownloadRequest.Destination = { _, _ in
          let documentsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0]
          var fileURL = documentsURL
          
          if FileManager.default.fileExists(atPath: fileURL.appendingPathComponent(attachment.name).path) {
            fileURL = fileURL.appendingPathComponent("\(Int.random(in: 1..<1000)).\(attachment.name)")
          } else {
            fileURL = fileURL.appendingPathComponent(attachment.name)
          }
          
          return (fileURL, [.createIntermediateDirectories])
        }
        
        trelloApi.downloadAttachment(url: attachment.url, to: destination) {}
        return
      }
      
      if isUrl {
        openURL(URL(string: attachment.url)!)
      } else {
        openWindow(value: attachment)
      }
    }) {
      HStack {
        VStack {
          if let mimeType = attachment.mimeType {
            switch(mimeType) {
            case "image/png", "image/jpeg", "image/gif":
              AttachmentImageView(attachment: $attachment)
                .frame(width: 64, height: 64)
            case "application/zip":
              Image(systemName: "paperclip")
                .font(.system(size: 32))
                .frame(width: 64, height: 64)
            case "application/pdf":
              Image(systemName: "doc.text")
                .font(.system(size: 32))
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
          
          if isUrl {
            Image(systemName: "globe")
              .font(.system(size: 32))
              .frame(width: 64, height: 64)
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
              .lineLimit(1)
            
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
    .buttonStyle(.plain)
    .onHover { hover in
      if (hover) {
        NSCursor.pointingHand.push()
      } else {
        NSCursor.pop()
      }
    }
  }
}

struct AttachmentView_Previews: PreviewProvider {
  static var previews: some View {
    AttachmentView(attachment: .constant(Attachment(id: "id", bytes: 0, date: TrelloApi.DateFormatter.string(from: Date.now), edgeColor: "", idMember: "", isUpload: true, mimeType: "image/png", name: "image", pos: 0, previews: [Preview(id: "", scaled: false, url: "", bytes: 0, height: 64, width: 64)], url: "")), onDelete: { })
  }
}
