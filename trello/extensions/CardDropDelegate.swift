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
  
  var trelloApi: TrelloApi;
  var boardVm: BoardState
  
  let item: String;
  @Binding var list: List;
  
  func validateDrop(info: DropInfo) -> Bool {
    // TODO: reimplement useful validation
    //        let dragBoard = NSPasteboard(name: .drag)
    //        guard let draggedItems = dragBoard.readObjects(forClasses: [NSString.self], options: nil) else { return false }
    //
    //        if draggedItems.count < 1 {
    //          return false
    //        }
    //
    //        let cardId = String(describing: draggedItems[0])
    //
    //        if let card = boardVm.board.cards.first(where: { card in card.id == cardId }) {
    //          if card.idList == list.id {
    //            return false
    //          }
    //        }
    
    return true
  }
  
  func dropEntered(info: DropInfo) {
    boardVm.stopUpdating()
    
    let dragBoard = NSPasteboard(name: .drag)
    guard let draggedItems = dragBoard.readObjects(forClasses: [NSString.self], options: nil) else { return }
    
    if draggedItems.count < 1 {
      return
    }
    
    let cardId = String(describing: draggedItems[0])
    
    guard let card = boardVm.board.cards.first(where: { card in card.id == cardId }) else { return }
    
    if card.idList == list.id {
      if item != cardId {
        let from = list.cards.firstIndex(where: { c in c.id == cardId})!
        let to = list.cards.firstIndex(where: { c in c.id == item})!
        if list.cards[to].id != cardId {
          withAnimation {
            list.cards.move(fromOffsets: IndexSet(integer: from),
                            toOffset: to > from ? to + 1 : to)
          }
        }
      }
    } else {
      // TODO: what do we even do here?
    }
  }
  
  func dropExited(info: DropInfo) {
    boardVm.startUpdating()
  }
  
  func performDrop(info: DropInfo) -> Bool {
    let dragBoard = NSPasteboard(name: .drag)
    guard let draggedItems = dragBoard.readObjects(forClasses: [NSString.self], options: nil) else { return false }
    
    if draggedItems.count < 1 {
      return false
    }
    
    let cardId = String(describing: draggedItems[0])
    
//    FIXME: we'll call the API right now, even if we drop a card on itself
//    if cardId == item {
//      return false
//    }
    
    guard let card = boardVm.board.cards.first(where: { card in card.id == cardId }) else { return false }
    if card.idList == list.id {
      let from = list.cards.firstIndex(where: { c in c.id == cardId})!
      let to = list.cards.firstIndex(where: { c in c.id == item})!
      
      print("moving inside same list. from index \(from) to index \(to)")
      
      withAnimation {
        moveCard(cardId: cardId, from: from, to: to)
      }
    } else {
      DispatchQueue.main.async {
        boardVm.updateCard(cardId: cardId, listId: list.id)
      }
    }
    
    return true
  }
  
  private func moveCard(cardId: String, from: Int, to: Int) {
    // HACK: get cards ordered by pos, because we already move the card inline so we lose the position data
    // it's also very early in the morning so I might just be wrong?
    let sortedCardPositions = list.cards.sorted(by: { c1, c2 in c1.pos < c2.pos }).map({ c in c.pos })
    
    var newPos: Float = 0.0
    if to + 1 >= self.list.cards.count {
      newPos = sortedCardPositions[self.list.cards.count - 1] + 1024
    } else if to == 0 {
      newPos = sortedCardPositions[0] - 1024
    } else {
      newPos = (sortedCardPositions[to - 1] + sortedCardPositions[to + 1]) / 2
    }
    
    DispatchQueue.main.async {
      print("moving card \(cardId) to \(to). old position \(sortedCardPositions[to]), new position \(newPos)")
      let cardIdx = self.list.cards.firstIndex(where: { c in c.id == cardId})!
      self.list.cards[cardIdx].pos = newPos
      boardVm.updateCard(cardId: cardId, pos: newPos)
      
      self.list.cards.move(fromOffsets: [from], toOffset: to)
    }
  }
}
