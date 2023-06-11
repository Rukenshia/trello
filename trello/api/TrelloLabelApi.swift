//
//  TrelloLabelApi.swift
//  trello
//
//  Created by Jan Christophersen on 12.11.22.
//

import Foundation
import Alamofire

extension TrelloApi {
  func updateLabel(labelId: String, name: String, color: LabelColor?, completion: @escaping (Label) -> Void) {
    self.request("/labels/\(labelId)", method: .put, parameters: [
      "name": name,
      "color": color?.rawValue ?? "",
    ], result: Label.self) { response, label in
      completion(label)
    }
  }
  
  func createLabel(boardId: String, name: String, color: LabelColor?, completion: @escaping (Label) -> Void) {
    self.request("/labels", method: .post, parameters: [
      "idBoard": boardId,
      "name": name,
      "color": color?.rawValue ?? "",
    ], result: Label.self) { response, label in
      completion(label)
    }
  }
  
  func deleteLabel(labelId: String, completion: @escaping () -> Void) {
    self.request("/labels/\(labelId)", method: .delete) { response in
      completion()
    }
  }
}
