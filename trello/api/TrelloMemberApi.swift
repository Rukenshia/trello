//
//  TrelloMemberApi.swift
//  trello
//
//  Created by Jan Christophersen on 12.11.22.
//

import Foundation
import Alamofire

extension TrelloApi {
  func getOrganizations(completion: @escaping ([Organization]) -> Void) {
    self.request("/members/me/organizations", result: [Organization].self) { response, organizations in
      completion(organizations)
    }
  }
  
  func addMemberToCard(cardId: String, memberId: String, completion: @escaping () -> Void) {
    self.request("/cards/\(cardId)/idMembers", method: .post, parameters: ["value": memberId]) { response in
      completion()
    }
  }
  
  func removeMemberFromCard(cardId: String, memberId: String, completion: @escaping () -> Void) {
    self.request("/cards/\(cardId)/idMembers/\(memberId)", method: .delete) { response in
      completion()
    }
  }
}
