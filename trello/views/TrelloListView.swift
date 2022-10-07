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
    @State var list: List;
    @State var listModel: ListViewModel;
    @State private var selection: Card? = nil;
    
    var background: Color {
        if list.cards.first(where: { card in card.name == "📍 HOY" }) == nil {
            return Color("SecondaryBg").opacity(0.95)
        }
        
        return Color("ListTodayBg").opacity(0.95)
    }
    
    var body: some View {
        VStack() {
            Text(list.name)
                .lineLimit(1)
                .font(.system(size: 18))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
            Divider().padding(.bottom, 6)
            SwiftUI.List {
                ForEach(list.cards, id: \.self) { card in
                    if card.name == "📍 HOY" {
                        EmptyView()
                    } else {
                        // TODO: Ideally the whole card should be draggable, but for some reason I couldn't figure
                        //       out it does not work because of the .onTapGesture handler in the CardView,
                        //       so now there's a "dot" you can drag from.
                        HStack {
                            Circle().fill(Color("CardBg")).frame(width: 8, height: 8).opacity(1)
                            CardView(card: card)
                        }
                    }
                }
                .onMove { source, dest in
                    if dest < 0 {
                        return
                    }
                    
                    self.list.cards.move(fromOffsets: source, toOffset: dest)
                }
                .onDelete { offsets in
                    self.list.cards.remove(atOffsets: offsets)
                }
                .onInsert(of: [String(describing: Card.self)], perform: onInsert)
            }
            .listStyle(.plain)
            .frame(minHeight: self.list.cards.count > 20 ? CGFloat(self.list.cards.count) * 40: CGFloat(self.list.cards.count) * 108, maxHeight: .infinity) // 76
            // TODO: I couldn't figure out how to do this properly. I want to show all items, but when
            //       the number of cards is too high, I'd like to limit it at some point. When minHeight
            //       is not set, the list has a height of 0 and nothing works
        }
        .padding()
        .background(background)
        .cornerRadius(16)
        .frame(minWidth: list.cards.count > 0 ? 300 : 150, minHeight: 150)
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

struct TrelloListView_Previews: PreviewProvider {
    static var previews: some View {
        TrelloListView(list: List(id: UUID().uuidString, name: "lunes", cards: [
            Card(id: UUID().uuidString, name: "Test Card", due: TrelloApi.DateFormatter.string(from: Date.now.addingTimeInterval(60))),
            Card(id: UUID().uuidString, name: "A very long card name to test how wrapping behaves", due: TrelloApi.DateFormatter.string(from: Date.now)),
            Card(id: UUID().uuidString, name: "Test Card", due: TrelloApi.DateFormatter.string(from: Date.now.addingTimeInterval(60))),
            Card(id: UUID().uuidString, name: "Test Card", due: TrelloApi.DateFormatter.string(from: Date.now.addingTimeInterval(60))),
            Card(id: UUID().uuidString, name: "Test Card", due: TrelloApi.DateFormatter.string(from: Date.now.addingTimeInterval(60))),
            Card(id: UUID().uuidString, name: "Test Card", due: TrelloApi.DateFormatter.string(from: Date.now.addingTimeInterval(60))),
            Card(id: UUID().uuidString, name: "Test Card", due: TrelloApi.DateFormatter.string(from: Date.now.addingTimeInterval(60))),
            Card(id: UUID().uuidString, name: "Test Card", due: TrelloApi.DateFormatter.string(from: Date.now.addingTimeInterval(60))),
        ]))
        .frame(width: 300)
    }
}
