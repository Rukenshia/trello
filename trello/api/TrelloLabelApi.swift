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
      if let idx = self.board.labels.firstIndex(where: { l in l.id == labelId }) {
        self.board.labels[idx] = label
      }
      
      completion(label)
    }
  }
  
  func createLabel(boardId: String, name: String, color: LabelColor?, completion: @escaping (Label) -> Void) {
    self.request("/labels", method: .post, parameters: [
      "idBoard": boardId,
      "name": name,
      "color": color?.rawValue ?? "",
    ], result: Label.self) { response, label in
      self.board.labels.append(label)
      
      completion(label)
    }
  }
  
  func deleteLabel(labelId: String, completion: @escaping () -> Void) {
    self.request("/labels/\(labelId)", method: .delete) { response in
      self.board.labels.removeAll(where: { l in l.id == labelId })
      
      completion()
    }
  }
}
