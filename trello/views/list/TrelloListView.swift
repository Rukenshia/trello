//
//  TrelloListView.swift
//  trello
//
//  Created by Jan Christophersen on 24.09.22.
//

import Combine
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
        return Color("TwZinc900").opacity(0.95)
    }
    
    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text(self.list.name)
                    .bold()
                    .lineLimit(1)
                    .font(.title3)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 8)
                Spacer()
//                Button(action: {
//
//                }) {
//
//                }
//                .buttonStyle(IconButton(icon: "gearshape", size: 12))
            }
            Divider()
            SwiftUI.List {
                ForEach(self.$list.cards) { card in
                    HStack {
                        Image(systemName: "list.bullet")
                        CardView(card: card)
                            .onDrag {
                                NSItemProvider(object: card.wrappedValue.id as NSString)
                            }
                    }
                }
                .onMove { source, dest in
                    if dest < 0 {
                        return
                    }
                    
                    for sourceIdx in source {
                        var newPos: Float = 0.0
                        if dest == self.list.cards.count {
                            newPos = self.list.cards[self.list.cards.count - 1].pos + 1024
                        } else if dest == 0 {
                            newPos = self.list.cards[0].pos - 1024
                        } else {
                            newPos = (self.list.cards[dest - 1].pos + self.list.cards[dest].pos) / 2
                        }
                        
                        self.list.cards[sourceIdx].pos = newPos
                        trelloApi.setCardPos(card: self.list.cards[sourceIdx], pos: newPos) { newCard in
                            
                        }
                    }
                    
                    
                    self.list.cards.move(fromOffsets: source, toOffset: dest)
                }
                .onDelete { offsets in
                    self.list.cards.remove(atOffsets: offsets)
                }
                .onInsert(of: [String(describing: Card.self)], perform: onInsert)
                .onDrop(of: ["public.text"], delegate: CardDropDelegate(trelloApi: self.trelloApi, list: self.$list))
                .deleteDisabled(true)
                .coordinateSpace(name: "cards")
            }
            .listStyle(.plain)
            // TODO: I couldn't figure out how to do this properly. I want to show all items, but when
            //       the number of cards is too high, I'd like to limit it at some point. When minHeight
            //       is not set, the list has a height of 0 and nothing works
            .frame(minHeight: self.list.cards.count > 20 ? CGFloat(self.list.cards.count) * 40: CGFloat(self.list.cards.count) * 86, maxHeight: .infinity)
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
                    self.addCardColor = Color("TwZinc700");
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
        .padding(8)
        .sheet(isPresented: $showAddCard) {
            AddCardView(list: self.$list, showAddCard: self.$showAddCard)
        }
        .background(background)
        .cornerRadius(4)
        .frame(minWidth: self.list.cards.count > 0 ? 300 : 150, minHeight: 180)
    }
    
    private func onInsert(at offset: Int, itemProviders: [NSItemProvider]) {
        
    }
}

struct TrelloListView_Previews: PreviewProvider {
    static var previews: some View {
        TrelloListView(list: .constant(List(id: "list", name: "list", cards: [
            Card(id: UUID().uuidString, name: "Test Card", due: TrelloApi.DateFormatter.string(from: Date.now.addingTimeInterval(60))),
            Card(id: UUID().uuidString, name: "A very long card name to test how wrapping behaves", due: TrelloApi.DateFormatter.string(from: Date.now)),
            Card(id: UUID().uuidString, name: "Test Card", due: TrelloApi.DateFormatter.string(from: Date.now.addingTimeInterval(60))),
            Card(id: UUID().uuidString, name: "Test Card", due: TrelloApi.DateFormatter.string(from: Date.now.addingTimeInterval(60))),
            Card(id: UUID().uuidString, name: "Test Card", due: TrelloApi.DateFormatter.string(from: Date.now.addingTimeInterval(60))),
            Card(id: UUID().uuidString, name: "Test Card", due: TrelloApi.DateFormatter.string(from: Date.now.addingTimeInterval(60))),
            Card(id: UUID().uuidString, name: "Test Card", due: TrelloApi.DateFormatter.string(from: Date.now.addingTimeInterval(60))),
            Card(id: UUID().uuidString, name: "Test Card", due: TrelloApi.DateFormatter.string(from: Date.now.addingTimeInterval(60))),
        ])))
        .environmentObject(TrelloApi(key: "", token: ""))
    }
}