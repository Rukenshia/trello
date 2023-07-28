//
//  CardAttachmentDropDelegate.swift
//  trello
//
//  Created by Jan Christophersen on 28.07.23.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct CardAttachmentDropDelegate: DropDelegate {
  let trelloApi: TrelloApi
  let cardId: String
  @Binding var dropping: Bool
  
  let onCreate: (Attachment) -> Void
  
  func validateDrop(info: DropInfo) -> Bool {
    return true
  }
  
  func dropEntered(info: DropInfo) {
    dropping = true
  }
  
  func dropExited(info: DropInfo) {
    dropping = false
  }
  
  func performDrop(info: DropInfo) -> Bool {
    // Load file info
    guard let itemProvider = info.itemProviders(for: [.fileURL]).first else { return false }
    
    itemProvider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { (urlData, error) in
      guard let data = urlData as? Data else { return }
      guard let url = URL(dataRepresentation: data, relativeTo: nil) else { return }
      
      let mimeType = url.mimeType()
      let fileName = url.lastPathComponent
      
      trelloApi.createCardAttachment(cardId: cardId, name: fileName, filePath: url, completion: { attachment in
        onCreate(attachment)
      })
    
    }
    
    return true
  }
}
