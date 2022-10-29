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
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        
        return formatter.string(from: card.dueDate!).uppercased()
    }
    
    private var formattedDueTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        return formatter.string(from: card.dueDate!).uppercased()
    }
    
    private var dueColor: Color {
        guard let dueStr = self.card.due else {
            return Color.clear;
        }
        let due = TrelloApi.DateFormatter.date(from: dueStr);
        
        if self.card.dueComplete {
            return Color("CardDueCompleteBg").opacity(0.85);
        }
        
        if Date.now > due! {
            return Color("CardOverdueBg").opacity(0.85);
        }
        
        let diff = Calendar.current.dateComponents([.day], from: Date.now, to: due!);
        
        if diff.day! > 0 {
            return Color.clear;
        }
        
        return Color("CardDueSoonBg").opacity(0.85);
    }
    
    private var duration: String? {
        guard let label = card.labels.first(where: { l in l.name.starts(with: "duration:") }) else {
            return nil
        }
        
        return label.name.replacingOccurrences(of: "duration:", with: "")
    }
    
    var body: some View {
        VStack {
            Text(formattedDueDate)
            Text(formattedDueTime)
            if let duration {
                HStack(spacing: 0) {
                    Image(systemName: "clock")
                    Text(duration)
                }
                .padding(.top, 2)
            }
        }
        .font(.system(size: 10, weight: .bold))
        .padding(4)
        .padding(.horizontal, 6)
        .frame(maxHeight: .infinity)
        .frame(width: 64)
        .background(dueColor)
        .overlay {
            if isHovering {
                VStack {
                    Button(action: {
                        self.trelloApi.markAsDone(card: card, completion: { newCard in
                            trelloApi.objectWillChange.send()
                            card.idLabels = newCard.idLabels
                            card = newCard
                        }, after_timeout: {
                            print("after_timeout")
                        })
                    }) {
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark")
                                .foregroundColor(Color("TwGreen200"))
                                .font(.system(size: 14))
                                .cornerRadius(4)
                            Spacer()
                        }
                        .frame(maxWidth: 16, maxHeight: .infinity)
                        .padding(4)
                        .padding(.horizontal, 16)
                        .frame(width: 64)
                        .background(Color("TwGreen900"))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .onHover { hover in
            self.isHovering = hover
        }
    }
}

struct CardDueView_Previews: PreviewProvider {
    static var previews: some View {
        CardDueView(card: .constant(Card(id: "card", name: "card")))
    }
}
