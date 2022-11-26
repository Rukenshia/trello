//
//  CardDueView.swift
//  trello
//
//  Created by Jan Christophersen on 29.10.22.
//

import SwiftUI

struct CardDueView: View {
  @EnvironmentObject var trelloApi: TrelloApi
  @Binding var card: Card
  
  @State var isHovering: Bool = false
  
  private var formattedDueDate: String {
    guard let due = card.dueDate else {
      return ""
    }
    
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM dd"
    
    return formatter.string(from: due)
  }
  
  private var formattedDueTime: String {
    guard let due = card.dueDate else {
      return ""
    }
    
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    
    return formatter.string(from: due)
  }
  
  private var dueColor: Color {
    guard let due = card.dueDate else {
      return Color.clear;
    }
    
    if self.card.dueComplete {
      return Color("CardDueCompleteBg").opacity(0.85);
    }
    
    if Date.now > due {
      return Color("CardOverdueBg").opacity(0.85);
    }
    
    let diff = Calendar.current.dateComponents([.day], from: Date.now, to: due);
    
    if diff.day! > 0 {
      return Color.clear;
    }
    
    return Color("CardDueSoonBg").opacity(0.85);
  }
  
  var body: some View {
    if let due = card.dueDate {
      Button(action: {
        self.trelloApi.markAsDone(card: self.card) { _ in }
      }) {
        HStack(alignment: .center, spacing: 2) {
          Image(systemName: "clock")
            .background(dueColor.clipShape(Circle()))
            .overlay {
              if isHovering {
                Button(action: {
                  self.trelloApi.markAsDone(card: self.card) { _ in }
                }) {
                  Image(systemName: "checkmark")
                    .padding(3)
                    .font(.system(size: 10))
                    .foregroundColor(Color("TwGreen200"))
                    .background(Color("TwGreen800"))
                    .clipShape(Circle())
                }
                .buttonStyle(.plain)
              }
            }
          if Calendar.current.isDateInToday(due) {
            Text(formattedDueTime)
          } else {
            Text(formattedDueDate)
          }
        }
        .onHover { hover in
          isHovering = hover
        }
        .padding(2)
        .background(isHovering ? Color("TwGreen800") : Color.clear)
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
      CardDueView(card: .constant(Card(id: "card", name: "card", due: TrelloApi.DateFormatter.string(from: Date.now))))
      CardDueView(card: .constant(Card(id: "card", name: "card", due: TrelloApi.DateFormatter.string(from: Date.now.advanced(by: 10)))))
      CardDueView(card: .constant(Card(id: "card", name: "card", due: TrelloApi.DateFormatter.string(from: Date.now.advanced(by: 1000000)))))
    }
  }
}
