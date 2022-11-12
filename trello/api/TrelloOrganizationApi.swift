//
//  TrelloOrganizationApi.swift
//  trello
//
//  Created by Jan Christophersen on 12.11.22.
//

import Foundation
import Alamofire

extension TrelloApi {
  func getOrganizationBoards(id: String, completion: @escaping ([BasicBoard]) -> Void) {
    self.request("/organizations/\(id)/boards", result: [BasicBoard].self) { response, boards in
      completion(boards)
    }
  }
}
