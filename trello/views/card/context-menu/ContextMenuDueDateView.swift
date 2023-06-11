//
//  ContextMenuDueDateView.swift
//  trello
//
//  Created by Jan Christophersen on 10.10.22.
//

import SwiftUI

struct ContextMenuDueDateView: View {
  @EnvironmentObject var boardVm: BoardState
  @EnvironmentObject var trelloApi: TrelloApi;
  
  @Binding var card: Card;
  
  @State private var date: Date = Date.now;
  
  var body: some View {
    VStack(alignment: .leading) {
      DatePicker("", selection: $date, displayedComponents: [.date]).datePickerStyle(.graphical)
      Text(date.formatted(.dateTime.day().month().year()))
        .padding(.horizontal, 8)
      DatePicker("", selection: $date, displayedComponents: [.hourAndMinute]).datePickerStyle(.stepperField)
        .frame(width: 160)
      HStack {
        if card.due != nil {
          Button(action: {
            boardVm.removeCardDue(cardId: card.id)
          }) {
            Text("Remove Due")
          }
          .buttonStyle(FlatButton(icon: "trash"))
          
          Spacer()
        }
        
        Button(action: {
          boardVm.updateCard(cardId: card.id, due: self.date)
        }) {
          Text("Save")
        }
        .buttonStyle(FlatButton())
      }
      .padding(.horizontal, 8)
    }
    .onAppear {
      if let due = self.card.dueDate {
        self.date = due
      }
    }
    .padding()
  }
}

struct ContextMenuDueDateView_Previews: PreviewProvider {
  static var previews: some View {
    ContextMenuDueDateView(card: .constant(Card(id: "id", name: "card name", due: "2022-10-10T07:25:24.331Z")))
  }
}
