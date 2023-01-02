//
//  DoneListView.swift
//  trello
//
//  Created by Jan Christophersen on 27.10.22.
//

import SwiftUI


struct DoneListView: View {
  @EnvironmentObject var trelloApi: TrelloApi

  @Binding var boardActions: [ActionUpdateCard]
  @Binding var list: List;
  @Binding var archivedCards: [Card]
  
  @State private var actionForCard: Dictionary<String, ActionUpdateCard> = Dictionary()
  
  var allCards: [Card] {
    list.cards + archivedCards
  }
  
  let bucketKeys: [String] = ["today", "yesterday", "this week", "this month", "older"]
  
  var sortedCards: [Card] {
    self.allCards.sorted{ (a: Card, b: Card) in
      var dateA = ""
      var dateB = ""
      
      if let actionA = actionForCard[a.id] {
        dateA = actionA.date
      }
      if let actionB = actionForCard[b.id] {
        dateB = actionB.date
      }
      
      if dateA.isEmpty && dateB.isEmpty {
        return a.dateLastActivity > b.dateLastActivity
      }
      
      if !dateA.isEmpty && dateB.isEmpty {
        return true
      }
      
      if dateA.isEmpty && !dateB.isEmpty {
        return false
      }
      
      return dateA > dateB
    }
  }
  
  var buckets: Dictionary<String, [Card]> {
    var dict: Dictionary<String, [Card]> = [
      "today": [],
      "yesterday": [],
      "this week": [],
      "this month": [],
      "older": [],
    ];
    
    let today: Date = Calendar.current.startOfDay(for: Date.now)
    let startOfWeek: Date = Calendar.current.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: Date.now).date!
    let startOfMonth: Date = Calendar.current.dateInterval(of: .month, for: Date.now)!.start
    
    for card in sortedCards {
      let startOfDay = Calendar.current.startOfDay(for: TrelloApi.DateFormatter.date(from: card.dateLastActivity)!)
      
      let diff = Calendar.current.dateComponents([.day], from: startOfDay, to: today)
      
      if diff.day! < 1 {
        dict["today"]?.append(card)
      } else if diff.day! < 2 {
        dict["yesterday"]?.append(card)
      } else if startOfDay > startOfWeek {
        dict["this week"]?.append(card)
      } else if startOfDay > startOfMonth {
        dict["this month"]?.append(card)
      } else {
        dict["older"]?.append(card)
      }
    }
    
    
    return dict
  }
  
  var body: some View {
    SwiftUI.List {
      ForEach(bucketKeys, id: \.self) { key in
        if self.buckets[key]!.count > 0 {
          Text(key)
            .font(.headline)
          ForEach(self.buckets[key]!) { card in
            HStack {
              if card.closed {
                Image(systemName: "archivebox")
              }
              Text(card.name)
            }
            .padding(4)
          }
        }
      }
    }
    .onChange(of: boardActions) { actions in
      var newDict = Dictionary<String, ActionUpdateCard>()
      
      // Take the first action as it should be the newest one
      for action in actions {
        if newDict[action.data.card.id] != nil {
          continue
        }
        
        if action.data.listBefore?.id == nil {
          // Reject changes that don't move the card
          continue
        }
        
        if action.data.listAfter?.id != list.id {
          // Reject changes that don't move the card to the done list
          continue
        }
        
        newDict[action.data.card.id] = action
      }
      
      actionForCard = newDict
      
    }
  }
}

struct DoneListView_Previews: PreviewProvider {
  static var previews: some View {
    DoneListView(boardActions: .constant([]), list: .constant(List(id: "list", name: "list", cards: [])), archivedCards: .constant([]))
  }
}
