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
  
  var body: some View {
    if let due = card.dueDate {
      Button(action: {
        self.trelloApi.markAsDone(card: self.card) { _ in }
      }) {
        HStack(alignment: .center, spacing: 2) {
          Image(systemName: "clock")
            .overlay {
              if isHovering {
                Button(action: {
                  self.trelloApi.markAsDone(card: self.card) { _ in }
                }) {
                  Image(systemName: "checkmark")
                    .padding(3)
                    .font(.system(size: 10))
                    .foregroundColor(Color("TwGreen200"))
                    .background(Color("CardDueCompleteBackground"))
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
          withAnimation(.easeIn(duration: 0.05)) {
            isHovering = hover
          }
        }
        .frame(alignment: .leading)
        .frame(minWidth: 60)
        .padding(2)
        .foregroundColor(isHovering ? Color("TwGreen200") : Color.primary)
        .background(isHovering ? Color("CardDueCompleteBackground") : dueColor)
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
        CardDueView(card: .constant(Card(id: "card", name: "card", due: TrelloApi.DateFormatter.string(from: Date.now))))
        CardDueView(card: .constant(Card(id: "card", name: "card", due: TrelloApi.DateFormatter.string(from: Date.now.advanced(by: 10)))))
        CardDueView(card: .constant(Card(id: "card", name: "card", due: TrelloApi.DateFormatter.string(from: Date.now.advanced(by: 1000000)))))
        CardDueView(card: .constant(Card(id: "card", name: "card", due: TrelloApi.DateFormatter.string(from: Date.now.advanced(by: 1000000)))), isHovering: true)
      }
      .padding()
      .background(Color("CardBackground"))
      .cornerRadius(4)
    }
    .padding()
  }
}
