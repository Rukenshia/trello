//
//  ContextMenuDueDateView.swift
//  trello
//
//  Created by Jan Christophersen on 10.10.22.
//

import SwiftUI

struct ContextMenuDueDateView: View {
    @EnvironmentObject var trelloApi: TrelloApi;
    @Binding var card: Card;
    
    @State private var date: Date = Date.now;
    
    var body: some View {
        VStack {
            DatePicker("", selection: $date, displayedComponents: [.date]).datePickerStyle(.graphical)
            DatePicker("", selection: $date, displayedComponents: [.hourAndMinute]).datePickerStyle(.stepperField)
            Button(action: {
                self.trelloApi.setCardDue(card: card, due: self.date, completion: { card in
                    print("\(card.name): due updated to \(TrelloApi.DateFormatter.string(from: self.date))")
                })
            }) {
                Text("Save")
            }
        }
        .onAppear {
            if let due = self.card.dueDate {
                self.date = due
            }
        }
    }
}

struct ContextMenuDueDateView_Previews: PreviewProvider {
    static var previews: some View {
        ContextMenuDueDateView(card: .constant(Card(id: "id", name: "card name", due: "2022-10-10T07:25:24.331Z")))
    }
}
