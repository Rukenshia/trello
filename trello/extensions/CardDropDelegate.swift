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
  
  @Binding var card: Card;
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
    if (card.id == Card.empty.id) {
      return
    }
    
    //    let dragBoard = NSPasteboard(name: .drag)
    //    guard let draggedItems = dragBoard.readObjects(forClasses: [NSString.self], options: nil) else { return }
    //
    //    if draggedItems.count < 1 {
    //      return
    //    }
    //
    //    let draggedCardId = String(describing: draggedItems[0])
    
    guard let draggedCard = boardVm.draggedCard else { return }
    guard let draggedCardIdx = boardVm.board.cards.firstIndex(where: { card in card.id == draggedCard.id }) else { return }
    
    
    if draggedCard.idList == list.id {
      if card.id != draggedCard.id {
        print("card.id: \(card.id) dropEntered for: \(draggedCard.id)")
        
        let from = list.cards.firstIndex(where: { c in c.id == draggedCard.id})!
        let to = list.cards.firstIndex(where: { c in c.id == card.id})!
        
//        if list.cards[to].id != draggedCard.id {
          DispatchQueue.main.async {
            withAnimation {
              
              let newPos = getNewPosition(cardId: draggedCard.id, toIndex: to, direction: to > from)
              
              list.cards[from].pos = newPos
              boardVm.board.cards[draggedCardIdx].pos = newPos
              boardVm.draggedCard!.pos = newPos
              
              list.cards.move(fromOffsets: IndexSet(integer: from),
                              toOffset: to)
            }
//          }
        }
      }
    } else {
      if card.id != draggedCard.id {
        if let to = list.cards.firstIndex(where: { c in c.id == card.id}) {
          withAnimation {
            // remove from old list
            if let oldListIdx = boardVm.board.lists.firstIndex(where: { l in l.id == draggedCard.idList }) {
              print("remove from old list: \(boardVm.board.lists[oldListIdx].name)")
              boardVm.board.lists[oldListIdx].cards = boardVm.board.lists[oldListIdx].cards.filter({ c in c.id != draggedCard.id })
              
            }
            
            boardVm.board.cards[draggedCardIdx].idList = list.id
            card.idList = list.id
            boardVm.draggedCard!.idList = list.id
            
            
            // add card to new list
            list.cards.insert(boardVm.board.cards[draggedCardIdx], at: to)
          }
        }
      }
    }
  }
  
  func performDrop(info: DropInfo) -> Bool {
    //    let dragBoard = NSPasteboard(name: .drag)
    //    guard let draggedItems = dragBoard.readObjects(forClasses: [NSString.self], options: nil) else { return false }
    //
    //    if draggedItems.count < 1 {
    //      return false
    //    }
    //
    //    let cardId = String(describing: draggedItems[0])
    
    //    FIXME: we'll call the API right now, even if we drop a card on itself
    //    if cardId == item {
    //      return false
    //    }
    
    
    
    guard let draggedCard = boardVm.draggedCard else { return false }
    
    
    if card.id == Card.empty.id { // in case this is the "drop zone" at the bottom / on an empty list
                                         // Move to bottom
      print("moving inside same list. to the bottom")
      
      withAnimation {
        moveCard(listId: list.id, cardId: draggedCard.id, to: list.cards.count - 1)
      }
      
      boardVm.startUpdating()
      return true
    }
    
    let to = list.cards.firstIndex(where: { c in c.id == card.id})!
    
    print("moving inside same list. to index \(to)")
    
    DispatchQueue.main.async {
      withAnimation {
        moveCard(listId: list.id, cardId: draggedCard.id, to: to)
      }
    }
    
    boardVm.startUpdating()
    return true
  }
  
  private func getNewPosition(cardId: String, toIndex: Int, direction: Bool) -> Float {
    let card = boardVm.board.cards.first(where: { c in c.id == cardId })!
    
    let sortedCards = list.cards.sorted(by: { c1, c2 in c1.pos < c2.pos })
    let sortedCardPositions = sortedCards.map({ c in c.pos })
    
    var newPos: Float = 0.0
    if toIndex + 1 >= self.list.cards.count {
      newPos = sortedCardPositions[self.list.cards.count - 1] + 1024
    } else if toIndex == 0 {
      newPos = sortedCardPositions[0] - 1024
    } else {
      
      
      guard let cardAbove = sortedCards.first(where: { c in c.pos == sortedCardPositions[toIndex - 1] }) else { return 0.0 }
      guard let cardBelow = sortedCards.first(where: { c in c.pos == sortedCardPositions[toIndex] }) else { return 0.0 }
//      
//      print("----")
//      print("drag direction: \(direction ? "down" : "up")")
//      print("dragged card: \(boardVm.draggedCard!.name) pos: \(boardVm.draggedCard!.pos)")
//      print("card above: \(cardAbove.name) pos: \(cardAbove.pos)")
//      print("card below: \(cardBelow.name) pos: \(cardBelow.pos)")
//      print("new calculcate position: \(newPos)")
      
      newPos = (cardAbove.pos + cardBelow.pos) / 2
    }
    
    return newPos
    
  }
  
  private func moveCard(listId: String, cardId: String, to: Int) {
    DispatchQueue.main.async {
      let cardIdx = self.list.cards.firstIndex(where: { c in c.id == cardId})!
      print("moving card \(cardId) to \(to). new position \(self.list.cards[cardIdx].pos)")
      boardVm.updateCard(cardId: cardId, listId: listId, pos: self.list.cards[cardIdx].pos)
    }
  }
}
