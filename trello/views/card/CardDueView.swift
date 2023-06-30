//
//  CardDueView.swift
//  trello
//
//  Created by Jan Christophersen on 29.10.22.
//

import SwiftUI
import Combine

struct CardDueView: View {
  let dueDate: Date
  let dueComplete: Bool
  var markAsDone: () -> Void = {}
  var compact: Bool = false
  
  @State var isHovering: Bool = false
  
  private var dueColor: Color {
    if dueComplete {
      return Color("CardDueCompleteBackground");
    }
    
    if Date.now > dueDate {
      return Color("CardOverdueBackground");
    }
    
    if !Calendar.current.isDate(Date.now, inSameDayAs: dueDate) {
      return Color.clear;
    }
    
    return Color("CardDueSoonBackground");
  }
  
  private var hoverButton: some View {
    Button(action: {
      markAsDone()
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
    if dueComplete {
      return Color("CardDueComplete");
    }
    
    if isHovering {
      return Color("TwGreen200")
    }
    
    if Date.now > dueDate {
        if compact {
          return Color("CardOverdueBackground")
        }
      
        return Color("CardOverdue")
    }
    
    if !Calendar.current.isDate(Date.now, inSameDayAs: dueDate) {
      return .primary;
    }
    
    return Color("CardDueSoon")
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
  
  private var imageColor: Color {
    if dueComplete {
      return Color("CardDueComplete");
    }
    
    if isHovering {
      return Color("TwGreen200")
    }
    
    if Date.now > dueDate {
      if compact {
        return Color("CardOverdue")
      }
      
      return Color("CardOverdue")
    }
    
    if !Calendar.current.isDate(Date.now, inSameDayAs: dueDate) {
      return .primary;
    }
    
    return Color("CardDueSoon")
  }
  
  private var dueString: String {
    if Calendar.current.isDateInToday(dueDate) {
      return TrelloApi.DateFormatterTime.string(from: dueDate)
    } else {
      return TrelloApi.DateFormatterDate.string(from: dueDate)
    }
  }
  
  var body: some View {
    Button(action: {
      markAsDone()
    }) {
      HStack(spacing: 2) {
        Image(systemName: "clock")
          .padding(.vertical, compact ? 1 : 0)
          .background(compact ? dueColor : Color.clear)
          .foregroundColor(imageColor)
          .clipShape(Circle())
          .overlay {
            if isHovering {
              hoverButton
            }
          }
        Text(dueString)
      }
      .onHover { hover in
        withAnimation(.easeIn(duration: 0.05)) {
          isHovering = hover
        }
      }
      .frame(minWidth: 60)
      .padding(.vertical, compact ? 1 : 2)
      .foregroundColor(foregroundColor)
      .background(backgroundColor)
      .cornerRadius(3)
    }
    .buttonStyle(.plain)
  }
}

struct CardDueView_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      VStack {
        CardDueView(dueDate: Date.now, dueComplete: false)
        CardDueView(dueDate: Date.now.advanced(by: 10), dueComplete: false)
        CardDueView(dueDate: Date.now.advanced(by: 1000000), dueComplete: false)
        CardDueView(dueDate: Date.now.advanced(by: 1000000), dueComplete: false, isHovering: true)
      }
      .padding()
      .background(Color("CardBackground"))
      .cornerRadius(4)
      
      VStack {
        CardDueView(dueDate: Date.now, dueComplete: false, compact: true)
        CardDueView(dueDate: Date.now.advanced(by: 10), dueComplete: false, compact: true)
        CardDueView(dueDate: Date.now.advanced(by: 1000000), dueComplete: false, compact: true)
        CardDueView(dueDate: Date.now.advanced(by: 1000000), dueComplete: false, compact: true, isHovering: true)
      }
      .padding()
      .background(Color("CardBackground"))
      .cornerRadius(4)
    }
    .padding()
  }
}
