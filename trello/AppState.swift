//
//  AppState.swift
//  trello
//
//  Created by Jan Christophersen on 05.03.23.
//

import Foundation

class AppState: ObservableObject {
  var api: TrelloApi?
  
  @Published var creatingCard: Bool
  @Published var selectedBoard: Board?
  @Published var loadingBoard: Bool
  @Published var showingDetails: Bool
  @Published var showingCardContextMenu: Bool
  
  init(api: TrelloApi?) {
    self.api = api
    self.creatingCard = false
    self.selectedBoard = nil
    self.loadingBoard = false
    self.showingDetails = false
    self.showingCardContextMenu = false
  }
  
  func selectBoard(id: String) {
    guard let api else {
      return
    }
    
    self.loadingBoard = true
    
    api.getBoard(id: id) { b in
      self.selectedBoard = b
      self.loadingBoard = false
    }
  }
}
