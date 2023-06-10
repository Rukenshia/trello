//
//  CardDueView.swift
//  trello
//
//  Created by Jan Christophersen on 29.10.22.
//

import SwiftUI
import Combine

struct CardDueView: View {
  @EnvironmentObject var trelloApi: TrelloApi
  let cardId: String // TODO: remove
  let dueDate: Date? // TODO: remove optional, use 
  let dueComplete: Bool
  var compact: Bool = false
  
  @State var isHovering: Bool = false
  
  private var formattedDueDate: String {
    guard let due = dueDate else {
      return ""
    }
    
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM dd"
    
    return formatter.string(from: due)
  }
  
  private var formattedDueTime: String {
    guard let due = dueDate else {
      return ""
    }
    
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    
    return formatter.string(from: due)
  }
  
  private var dueColor: Color {
    guard let due = dueDate else {
      return Color.clear;
    }
    
    if dueComplete {
      return Color("CardDueCompleteBackground").opacity(0.85);
    }
    
    if Date.now > due {
      return Color("CardOverdueBackground").opacity(0.85);
    }
    
    let diff = Calendar.current.dateComponents([.day], from: Date.now, to: due);
    
    if diff.day! > 0 {
      return Color.clear;
    }
    
    return Color("CardDueSoonBackground").opacity(0.85);
  }
  
  private var hoverButton: some View {
    Button(action: {
      self.trelloApi.markAsDone(cardId: self.cardId) { _ in }
    }) {
      Image(systemName: "checkmark")
        .padding(10)
        .font(.system(size: 10))
        .foregroundColor(Color("TwGreen200"))
        .background(Color("CardDueCompleteBackground"))
        .clipShape(Circle())
    }
    .buttonStyle(.plain)
  }
  
  private var foregroundColor: Color {
    return isHovering ? Color("TwGreen200") : .primary
  }
  
  private var backgroundColor: Color {
    if isHovering {
      return Color("CardDueCompleteBackground")
    }
    
    if compact {
      return .clear
    }
    
    return dueColor
  }
  
  var body: some View {
    if let due = dueDate {
      Button(action: {
        self.trelloApi.markAsDone(cardId: cardId) { _ in }
      }) {
        HStack(alignment: .center, spacing: 2) {
          Image(systemName: "clock")
            .padding(compact ? 1 : 0)
            .background(compact ? dueColor : Color.clear)
            .clipShape(Circle())
            .overlay {
              if isHovering {
                hoverButton
              }
            }
          if Calendar.current.isDateInToday(due) {
            Text(formattedDueTime)
          } else {
            Text(formattedDueDate)
          }
        }
        .onHover { hover in
          withAnimation(.easeIn(duration: 0.05)) {
            isHovering = hover
          }
        }
        .frame(alignment: .leading)
        .frame(minWidth: 60)
        .padding(compact ? 1 : 2)
        .foregroundColor(foregroundColor)
        .background(backgroundColor)
        .cornerRadius(4)
      }
      .buttonStyle(.plain)
    } else {
      EmptyView()
    }
  }
}

struct CardDueView_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      VStack {
        CardDueView(cardId: "card", dueDate: Date.now, dueComplete: false)
        CardDueView(cardId: "card", dueDate: Date.now.advanced(by: 10), dueComplete: false)
        CardDueView(cardId: "card", dueDate: Date.now.advanced(by: 1000000), dueComplete: false)
        CardDueView(cardId: "card", dueDate: Date.now.advanced(by: 1000000), dueComplete: false, isHovering: true)
      }
      .padding()
      .background(Color("CardBackground"))
      .cornerRadius(4)
      
      VStack {
        CardDueView(cardId: "card", dueDate: Date.now, dueComplete: false, compact: true)
        CardDueView(cardId: "card", dueDate: Date.now.advanced(by: 10), dueComplete: false, compact: true)
        CardDueView(cardId: "card", dueDate: Date.now.advanced(by: 1000000), dueComplete: false, compact: true)
        CardDueView(cardId: "card", dueDate: Date.now.advanced(by: 1000000), dueComplete: false, compact: true, isHovering: true)
      }
      .padding()
      .background(Color("CardBackground"))
      .cornerRadius(4)
    }
    .padding()
  }
}
