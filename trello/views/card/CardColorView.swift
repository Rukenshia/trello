//
//  CardColorView.swift
//  trello
//
//  Created by Jan Christophersen on 14.10.22.
//

import SwiftUI

struct CardColorView: View {
    @EnvironmentObject var trelloApi: TrelloApi;
    @Binding var card: Card;
    @Binding var label: Label;
    @Binding var labels: [Label];
    @Binding var show: Bool;
    
    @State var color: AnyView = AnyView(Color(.clear));
    
    var body: some View {
        Button(action: {
            self.trelloApi.removeLabelsFromCard(card: self.card, labelIds: self.labels.filter({ l in l.name.contains("color:") && l.name != label.name }).map{ l in l.id }, completion: { newCard in
                    self.trelloApi.addLabelsToCard(card: self.card, labelIds: [label.id], completion: { newCard in
                        print("label added")
                        show = false;
                    })
                })
        }) {
            Text("click me pretty please")
                .foregroundColor(.clear)
                .frame(width: 64, height: 48)
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle()) // TODO: cannot click entire button
        .background(self.color)
        .cornerRadius(4)
        .onHover { hover in
            if hover {
                self.color = AnyView(self.color.brightness(0.1))
            } else {
                self.color = AnyView(Color("CardBg_\(label.name.split(separator: ":")[1])"));
            }
        }
        .onAppear {
            self.color = AnyView(Color("CardBg_\(label.name.split(separator: ":")[1])"));
        }
    }
}

struct CardColorView_Previews: PreviewProvider {
    static var previews: some View {
        CardColorView(card: .constant(Card(id: "card-id", name: "card-name")), label: .constant(Label(id: "amber", name: "color:amber")), labels: .constant([Label(id: "emerald", name: "color:emerald"), Label(id: "amber", name: "color:amber")]), show: .constant(false))
    }
}
