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
  
  @State private var showMenu: Bool = false
  
  var background: Color {
    return Color("ListBackground").opacity(0.95)
  }
  
  // TODO: I couldn't figure out how to do this properly. I want to show all items, but when
  //       the number of cards is too high, I'd like to limit it at some point. When minHeight
  //       is not set, the list has a height of 0 and nothing works
  var listHeight: CGFloat {
    min((NSApp.windows.first?.contentView?.bounds.height ?? .infinity) - 200, self.list.cards.count > 20 ? CGFloat(self.list.cards.count) * 40: CGFloat(self.list.cards.count) * 120)
  }
  
  var body: some View {
    VStack(spacing: 4) {
      HStack {
        TrelloListNameView(list: self.$list)
        Spacer()
        Button(action: {
          self.showMenu = true
        }) {
          
        }
        .buttonStyle(IconButton(icon: "ellipsis", iconColor: .primary, size: 12, color: .clear, hoverColor: .clear))
        .popover(isPresented: self.$showMenu, arrowEdge: .bottom) {
          TrelloListMenuView(list: self.$list)
        }
      }
      Divider()
      SwiftUI.List {
        ForEach(self.$list.cards) { card in
          CardView(card: card)
            .onDrag {
              NSItemProvider(object: card.wrappedValue.id as NSString)
            }
            .padding(.bottom, 4)
        }
        .onMove { source, dest in
          if dest < 0 {
            return
          }
          
          for sourceIdx in source {
            moveCard(cardId: self.list.cards[sourceIdx].id, from: sourceIdx, to: dest)
          }
        }
        .onDelete { offsets in
          self.list.cards.remove(atOffsets: offsets)
        }
        .onInsert(of: ["public.text"], perform: onInsert)
        .onDrop(of: ["public.text"], delegate: CardDropDelegate(trelloApi: self.trelloApi, list: self.$list))
        .deleteDisabled(true)
      }
      .listStyle(.plain)
      .frame(minHeight: self.listHeight)
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
    .onDrop(of: ["public.text"], delegate: CardDropDelegate(trelloApi: self.trelloApi, list: self.$list))
    .padding(8)
    .sheet(isPresented: $showAddCard) {
      AddCardView(list: self.$list, showAddCard: self.$showAddCard)
    }
    .background(background)
    .cornerRadius(4)
    .frame(minWidth: self.list.cards.count > 0 ? 290 : 150, minHeight: 180)
  }
  
  private func moveCard(cardId: String, from: Int, to: Int) {
    
    var newPos: Float = 0.0
    if to == self.list.cards.count {
      newPos = self.list.cards[self.list.cards.count - 1].pos + 1024
    } else if to == 0 {
      newPos = self.list.cards[0].pos - 1024
    } else {
      newPos = (self.list.cards[to - 1].pos + self.list.cards[to].pos) / 2
    }
    
    DispatchQueue.main.async {
      print(from, to)
      self.list.cards[from].pos = newPos
      trelloApi.updateCard(cardId: cardId, pos: newPos) { newCard in }
      
      self.list.cards.move(fromOffsets: [from], toOffset: to)
    }
  }
  
  private func onInsert(at offset: Int, itemProviders: [NSItemProvider]) {
    for item in itemProviders {
      _ = item.loadObject(ofClass: String.self) { droppedString, _ in
        if let cardId = droppedString {
          if let from = list.cards.firstIndex(where: { card in card.id == cardId }) {
            moveCard(cardId: cardId, from: from, to: offset)
            return
          }
          
          // Card was probably dropped from another list - transfer it
          if let card = trelloApi.board.cards.first(where: { card in card.id == cardId }) {
            if card.idList == list.id {
              print("something weird happened")
              return
            }
          }
          
          DispatchQueue.main.async {
            trelloApi.updateCard(cardId: cardId, listId: list.id) { card in
            }
          }
        }
      }
    }
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
    .environmentObject(TrelloApi(key: Preferences().trelloKey!, token: Preferences().trelloToken!))
    .frame(height: 1200)
  }
}
