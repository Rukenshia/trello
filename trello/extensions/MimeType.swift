//
//  MimeType.swift
//  trello
//
//  Created by Jan Christophersen on 28.07.23.
//

import Foundation
import UniformTypeIdentifiers

extension NSString {
  public func mimeType() -> String {
    if let mimeType = UTType(filenameExtension: self.pathExtension)?.preferredMIMEType {
      return mimeType
    }
    else {
      return "application/octet-stream"
    }
  }
}

extension URL {
  public func mimeType() -> String {
    if let mimeType = UTType(filenameExtension: self.pathExtension)?.preferredMIMEType {
      return mimeType
    }
    else {
      return "application/octet-stream"
    }
  }
}

extension String {
  public func mimeType() -> String {
    return (self as NSString).mimeType()
  }
}
