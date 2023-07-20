//
//  AppState.swift
//  trello
//
//  Created by Jan Christophersen on 05.03.23.
//

import Foundation

class BoardState: ObservableObject {
  var api: TrelloApi
  @Published var board: Board
  @Published var updating: Bool
  
  
  init(api: TrelloApi, board: Board) {
    self.api = api
    self.board = board
    self.updating = true
  }
  
  func selectBoard(board: Board) {
    if (!updating) {
      print("rejecting board update")
      
      return
    }
    
    self.board = board
  }
  
  func startUpdating() {
    updating = true
  }
  
  func stopUpdating() {
    updating = false
  }
  
  
  func createCard(listId: String, sourceCardId: String) {
    api.createCard(listId: listId, sourceCardId: sourceCardId) { card in
      
      let listIdx = self.board.lists.firstIndex(where: { l in l.id == card.idList })!
      
      self.board.lists[listIdx].cards.append(card)
    }
  }
  
  func createCard(listId: String, name: String, description: String) {
    api.createCard(listId: listId, name: name, description: description) { card in
      
      let listIdx = self.board.lists.firstIndex(where: { l in l.id == card.idList })!
      
      self.board.lists[listIdx].cards.append(card)
    }
  }
  
  func addLabelsToCard(cardId: String, labelIds: [String]) {
    api.addLabelsToCard(cardId: cardId, labelIds: labelIds) { card in
      let listIdx = self.board.lists.firstIndex(where: { l in l.id == card.idList })!
      let cardIdx = self.board.lists[listIdx].cards.firstIndex(where: { c in c.id == card.id })!
      
      self.board.lists[listIdx].cards[cardIdx] = card
    }
  }
  
  func removeLabelsFromCard(card: Card, labelIds: [String]) { // TODO: cardId
    api.removeLabelsFromCard(card: card, labelIds: labelIds) { card in
      let listIdx = self.board.lists.firstIndex(where: { l in l.id == card.idList })!
      let cardIdx = self.board.lists[listIdx].cards.firstIndex(where: { c in c.id == card.id })!
      
      self.board.lists[listIdx].cards[cardIdx] = card
    }
  }
  
  func updateCard(cardId: String, cover: CardCover) {
    api.updateCard(cardId: cardId, cover: cover) { card in
      let listIdx = self.board.lists.firstIndex(where: { l in l.id == card.idList })!
      let cardIdx = self.board.lists[listIdx].cards.firstIndex(where: { c in c.id == card.id })!
      
      self.board.lists[listIdx].cards[cardIdx] = card
      
    }
  }
  
  func removeCardCover(cardId: String) {
    api.removeCardCover(cardId: cardId) { card in
      let listIdx = self.board.lists.firstIndex(where: { l in l.id == card.idList })!
      let cardIdx = self.board.lists[listIdx].cards.firstIndex(where: { c in c.id == card.id })!
      
      self.board.lists[listIdx].cards[cardIdx] = card
      
    }
  }
  
  func updateCard(cardId: String, listId: String? = nil, memberIds: [String]? = nil, due: Date? = nil, dueComplete: Bool? = nil, desc: String? = nil, name: String? = nil, pos: Float? = nil, closed: Bool? = nil) {
    api.updateCard(cardId: cardId, listId: listId, memberIds: memberIds, due: due, dueComplete: dueComplete, desc: desc, name: name, pos: pos, closed: closed) { card in
      if let listId = listId {
        // find old card
        if var card = self.board.cards.first(where: { card in card.id == cardId }) {
          // Remove from old list and add to new locally
          if let oldList = self.board.lists.firstIndex(where: { list in list.id == card.idList }) {
            if let index = self.board.lists[oldList].cards.firstIndex(of: card) {
              self.board.lists[oldList].cards.remove(at: index)
            }
          }
          
          card.idList = listId
          
          if let newList = self.board.lists.firstIndex(where: { list in list.id == listId }) {
            self.board.lists[newList].cards.append(card)
            
            // If the card was moved within the list, reorder it
            self.board.lists[newList].cards = self.board.lists[newList].cards.sorted(by: { a, b in
              return a.pos < b.pos
            })
          }
          
          // Update the list on the card so that you can move the card again
          if let index = self.board.cards.firstIndex(where: { card in card.id == cardId }) {
            self.board.cards[index].idList = listId
          }
        } else {
          if let newList = self.board.lists.firstIndex(where: { list in list.id == listId }) {
            self.board.lists[newList].cards.append(card)
          }
        }
      } else {
        if let listIdx = self.board.lists.firstIndex(where: { l in l.id == card.idList }) {
          if let cardIdx = self.board.lists[listIdx].cards.firstIndex(where: { c in c.id == card.id }) {
            
            self.board.lists[listIdx].cards[cardIdx] = card
          }
        }
      }
    }
  }
  
  func markCardAsDone(cardId: String) {
    guard let doneLabel = self.board.labels.first(where: { label in label.name == "done"}) else {
      return
    }
    
    // FIXME: update when switching to async/await
    self.updateCard(cardId: cardId, dueComplete: true)
    self.addLabelsToCard(cardId: cardId, labelIds: [doneLabel.id])
  }
  
  func removeCardDue(cardId: String) {
    api.removeCardDue(cardId: cardId) { card in
      let listIdx = self.board.lists.firstIndex(where: { l in l.id == card.idList })!
      let cardIdx = self.board.lists[listIdx].cards.firstIndex(where: { c in c.id == card.id })!
      
      self.board.lists[listIdx].cards[cardIdx].due = nil
    }
  }
  
  func createList(name: String) {
    api.createList(boardId: self.board.id, name: name) { list in
      self.board.lists.append(list)
    }
  }
  
  func archiveList(listId: String) {
    api.archiveList(listId: listId) {
      self.board.lists = self.board.lists.filter{ l in l.id != listId }
    }
  }
  
  func setListName(listId: String, name: String) {
    api.setListName(listId: listId, name: name) { list in
      let listIdx = self.board.lists.firstIndex(where: { l in l.id == listId })!
      
      self.board.lists[listIdx].name = name
    }
  }
  
  func moveList(listId: String, pos: String) {
    api.moveList(listId: listId, pos: pos) { list in
      let listIdx = self.board.lists.firstIndex(where: { l in l.id == list.id })!
      
      self.board.lists[listIdx].pos = list.pos
    }
  }
  
  func addMemberToCard(cardId: String, memberId: String) {
    api.addMemberToCard(cardId: cardId, memberId: memberId) {
      let cardIdx = self.board.cards.firstIndex(where: { c in c.id == cardId })!
      let cardListId = self.board.cards[cardIdx].idList
      
      self.board.cards[cardIdx].idMembers.append(memberId)
      
      if let listIdx = self.board.lists.firstIndex(where: { l in l.id == cardListId }) {
        let cardIdx = self.board.lists[listIdx].cards.firstIndex(where: { c in c.id == cardId })!
        
        self.board.lists[listIdx].cards[cardIdx].idMembers.append(memberId)
      }
    }
  }
  
  func removeMemberFromCard(cardId: String, memberId: String) {
    api.removeMemberFromCard(cardId: cardId, memberId: memberId) {
      let cardIdx = self.board.cards.firstIndex(where: { c in c.id == cardId })!
      let cardListId = self.board.cards[cardIdx].idList
      
      self.board.cards[cardIdx].idMembers.removeAll(where: { m in m == memberId })
      
      if let listIdx = self.board.lists.firstIndex(where: { l in l.id == cardListId }) {
        let cardIdx = self.board.lists[listIdx].cards.firstIndex(where: { c in c.id == cardId })!
        
        self.board.lists[listIdx].cards[cardIdx].idMembers.removeAll(where: { m in m == memberId })
      }
    }
  }
  
  func createLabel(name: String, color: LabelColor?) {
    api.createLabel(boardId: board.id, name: name, color: color) { label in
      self.board.labels.append(label)
    }
  }
  
  func updateLabel(labelId: String, name: String, color: LabelColor?) {
    api.updateLabel(labelId: labelId, name: name, color: color) { label in
      if let idx = self.board.labels.firstIndex(where: { l in l.id == labelId }) {
        
        self.board.labels[idx] = label
      } else {
        print("label \(labelId) updated, but could not be found in list of labels in board")
      }
    }
  }
}
