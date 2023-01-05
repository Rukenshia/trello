//
//  ImageCache.swift
//  trello
//
//  Created by Jan Christophersen on 02.01.23.
//

import Foundation

extension URLCache {
  static let imageCache = URLCache(memoryCapacity: 512*1000*1000, diskCapacity: 10*1000*1000*1000)
}
