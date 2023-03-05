//
//  TrelloMemberApi.swift
//  trello
//
//  Created by Jan Christophersen on 12.11.22.
//

import Foundation
import Alamofire

extension TrelloApi {
  func getOrganizations(memberId: String = "me", completion: @escaping ([Organization]) -> Void) {
    self.request("/members/\(memberId)/organizations", result: [Organization].self) { response, organizations in
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
  
  func getMemberBoardStars(memberId: String = "me", completion: @escaping ([BoardStar]) -> Void) {
    self.request("/members/\(memberId)/boardStars", result: [BoardStar].self) { response, boardStars in
      completion(boardStars)
    }
  }
  
  func createMemberBoardStar(memberId: String = "me", boardId: String, position: String = "bottom", completion: @escaping (BoardStar) -> Void) {
    self.request("/members/\(memberId)/boardStars", method: .post, parameters: ["idBoard": boardId, "pos": position]) { response, boardStar in
      completion(boardStar)
    }
  }
  
  func deleteMemberBoardStar(memberId: String = "me", boardStarId: String, completion: @escaping () -> Void) {
    self.request("/members/\(memberId)/boardStars/\(boardStarId)", method: .delete) { response in
      completion()
    }
  }
}
