//
//  CardDropDelegate.swift
//  trello
//
//  Created by Jan Christophersen on 24.10.22.
//

import Foundation
import SwiftUI

struct CardDropDelegate: DropDelegate {
  @EnvironmentObject var state: AppState
  @EnvironmentObject var boardVm: BoardState
  
  var trelloApi: TrelloApi;
  @Binding var list: List;
  
  func validateDrop(info: DropInfo) -> Bool {
    let dragBoard = NSPasteboard(name: .drag)
    guard let draggedItems = dragBoard.readObjects(forClasses: [NSString.self], options: nil) else { return false }
    
    if draggedItems.count < 1 {
      return false
    }
    
    let cardId = String(describing: draggedItems[0])
    
    if let card = boardVm.board.cards.first(where: { card in card.id == cardId }) {
      if card.idList == list.id {
        return false
      }
    }
    
    return true
  }
  
  func performDrop(info: DropInfo) -> Bool {
    let dragBoard = NSPasteboard(name: .drag)
    guard let draggedItems = dragBoard.readObjects(forClasses: [NSString.self], options: nil) else { return false }
    
    if draggedItems.count < 1 {
      return false
    }
    
    let cardId = String(describing: draggedItems[0])
    
    if let card = boardVm.board.cards.first(where: { card in card.id == cardId }) {
      if card.idList == list.id {
        return false
      }
    }
    
    DispatchQueue.main.async {
      boardVm.updateCard(cardId: cardId, listId: list.id)
    }
    
    return true
  }
}
