//
//  TrelloListView.swift
//  trello
//
//  Created by Jan Christophersen on 24.09.22.
//

import SwiftUI

extension NSTableView {
    open override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        
        backgroundColor = NSColor.clear
        enclosingScrollView!.drawsBackground = false
        
    }
}

struct TrelloListView: View {
    @EnvironmentObject var trelloApi: TrelloApi;
    @Binding var list: List;
    
    @State private var selection: Card? = nil;
    @State private var addCardColor: Color = Color(.clear);
    @State private var showAddCard: Bool = false;
    
    var background: Color {
        if self.list.cards.first(where: { card in card.name == "📍 HOY" }) == nil {
            return Color("SecondaryBg").opacity(0.95)
        }
        
        return Color("ListTodayBg").opacity(0.95)
    }
    
    var body: some View {
        VStack() {
            Text(self.list.name)
                .lineLimit(1)
                .font(.system(size: 16))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .padding(.top, 8)
            Divider()
            SwiftUI.List(self.list.cards.indices, id: \.self) { index in
                Safe(self.$list.cards, index: index) { card in
                    CardView(card: card)
                }
//                .onMove { source, dest in
//                    if dest < 0 {
//                        return
//                    }
//                    
//                    self.list.cards.move(fromOffsets: source, toOffset: dest)
//                }
//                .onDelete { offsets in
//                    self.list.cards.remove(atOffsets: offsets)
//                }
//                .onInsert(of: [String(describing: Card.self)], perform: onInsert)
                .deleteDisabled(true)
            }
            .listStyle(.plain)
            // TODO: I couldn't figure out how to do this properly. I want to show all items, but when
            //       the number of cards is too high, I'd like to limit it at some point. When minHeight
            //       is not set, the list has a height of 0 and nothing works
            .frame(minHeight: self.list.cards.count > 20 ? CGFloat(self.list.cards.count) * 40: CGFloat(self.list.cards.count) * 108, maxHeight: .infinity) // 76
            Button(action: {
                self.showAddCard = true
            }) {
                HStack {
                    Image(systemName: "plus")
                    Text("Add card")
                }
            }
            .onHover { hover in
                if hover {
                    self.addCardColor = Color("CardBg");
                    return;
                }
                
                self.addCardColor = Color(.clear);
                return;
            }
            .buttonStyle(.plain)
            .padding(4)
            .background(self.addCardColor)
            .cornerRadius(4)
        }
        .padding(4)
        .sheet(isPresented: $showAddCard) {
            AddCardView(list: self.$list, showAddCard: self.$showAddCard)
        }
        .background(background)
        .cornerRadius(8)
        .frame(minWidth: self.list.cards.count > 0 ? 300 : 150, minHeight: 150)
    }
    
    private func onInsert(at offset: Int, itemProvider: [NSItemProvider]) {
        //        for provider in itemProvider {
        //            if provider.canLoadObject(ofClass: Card.self) {
        //                _ = provider.loadObject(ofClass: Card.self) { card, error in
        //                    DispatchQueue.main.async {
        //                        self.list.cards.insert(card!, at: offset)
        //                    }
        //                }
        //            }
        //        }
        print("onInsert")
    }
}

//struct TrelloListView_Previews: PreviewProvider {
//    static var previews: some View {
//        TrelloListView(listIdx: 0, list: List(id: UUID().uuidString, name: "lunes", cards: []), list: ListViewModel(cards: [
//            Card(id: UUID().uuidString, name: "Test Card", due: TrelloApi.DateFormatter.string(from: Date.now.addingTimeInterval(60))),
//            Card(id: UUID().uuidString, name: "A very long card name to test how wrapping behaves", due: TrelloApi.DateFormatter.string(from: Date.now)),
//            Card(id: UUID().uuidString, name: "Test Card", due: TrelloApi.DateFormatter.string(from: Date.now.addingTimeInterval(60))),
//            Card(id: UUID().uuidString, name: "Test Card", due: TrelloApi.DateFormatter.string(from: Date.now.addingTimeInterval(60))),
//            Card(id: UUID().uuidString, name: "Test Card", due: TrelloApi.DateFormatter.string(from: Date.now.addingTimeInterval(60))),
//            Card(id: UUID().uuidString, name: "Test Card", due: TrelloApi.DateFormatter.string(from: Date.now.addingTimeInterval(60))),
//            Card(id: UUID().uuidString, name: "Test Card", due: TrelloApi.DateFormatter.string(from: Date.now.addingTimeInterval(60))),
//            Card(id: UUID().uuidString, name: "Test Card", due: TrelloApi.DateFormatter.string(from: Date.now.addingTimeInterval(60))),
//        ]))
//        .frame(width: 300)
//    }
//}
