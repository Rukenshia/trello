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

enum PopoverState {
  case none;
  
  case moveToList;
  case manageLabels;
  case dueDate;
  case cardColor;
  case editCard;
  case manageMembers
}

struct TrelloListView: View {
  @EnvironmentObject var trelloApi: TrelloApi
  @EnvironmentObject var appState: AppState
  @EnvironmentObject var boardVm: BoardState
  
  @Binding var list: List
  @Binding var scale: CGFloat
  
  @State private var selection: Card? = nil
  @State private var addCardColor: Color = Color(.clear)
  @State private var showAddCard: Bool = false
  
  @State private var showMenu: Bool = false
  
  @State private var width: CGFloat = 150
  
  var background: Color {
    return Color("ListBackground").opacity(0.6)
  }
  
  var body: some View {
    VStack(spacing: 4) {
      HStack {
        TrelloListNameView(listId: list.id, name: list.name, onRename: { newName in
          boardVm.setListName(listId: list.id, name: newName)
        })
        .font(.system(size: 12 * scale))
        Spacer()
        Button(action: {
          self.showMenu = true
        }) {
          
        }
        .buttonStyle(IconButton(icon: "ellipsis", iconColor: .primary, size: 12 * scale, color: .clear, hoverColor: .clear))
        .popover(isPresented: self.$showMenu, arrowEdge: .bottom) {
          TrelloListMenuView(listId: list.id)
        }
      }
      Divider()
      SwiftUI.List {
        if $list.cards.count == 0 {
          if !showAddCard {
            Spacer()
              .frame(height: 180 * scale)
              .onDrop(of: ["public.text"], delegate: CardDropDelegate(trelloApi: self.trelloApi, boardVm: boardVm, list: self.$list))
          }
        } else {
          ForEach(self.$list.cards, id: \.id) { card in
            CardView(card: card,
                     scale: $scale)
            .onDrag {
              NSItemProvider(object: card.id as NSString)
            }
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
          .onDrop(of: ["public.text"], delegate: CardDropDelegate(trelloApi: self.trelloApi, boardVm: boardVm, list: self.$list))
          .deleteDisabled(true)
        }
        
        if showAddCard {
          AddCardView(list: self.list, showAddCard: self.$showAddCard, onFocusLost: {
            showAddCard = false
          })
        }
      }
      .listStyle(.plain)
      .scrollIndicators(.never) // FIXME: with the scroll indicators visible, there's always some white background
      Button(action: {
        self.showAddCard = true
        
        withAnimation {
          self.setWidth()
        }
      }) {
        HStack {
          Spacer()
          Image(systemName: "plus")
          Text("Add card")
          Spacer()
        }
        .padding(4 * scale)
        .padding(.vertical, 6 * scale)
        .background(self.addCardColor)
        .cornerRadius(4)
        .clipShape(Rectangle())
        .onHover { hover in
          if hover {
            self.addCardColor = Color("ButtonBackground");
            return;
          }
          
          self.addCardColor = Color(.clear);
          return;
        }
      }
      .buttonStyle(.plain)
    }
    .onDrop(of: ["public.text"], delegate: CardDropDelegate(trelloApi: self.trelloApi, boardVm: boardVm, list: self.$list))
    .onChange(of: list.cards) { cards in
      withAnimation {
        setWidth()
      }
    }
    .onChange(of: scale) { scale in
      setWidth()
    }
    .onChange(of: showAddCard) { nv in
      appState.creatingCard = nv
    }
    .onAppear {
      setWidth()
    }
    .padding(8)
    .background(background)
    .cornerRadius(4)
    .frame(idealWidth:width)
  }
  
  private func setWidth() {
    self.width = self.list.cards.count > 0 || showAddCard ? 260 * scale : 150 * scale
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
      boardVm.updateCard(cardId: cardId, pos: newPos)
      
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
          if let card = boardVm.board.cards.first(where: { card in card.id == cardId }) {
            if card.idList == list.id {
              print("something weird happened")
              return
            }
          }
          
          DispatchQueue.main.async {
            boardVm.updateCard(cardId: cardId, listId: list.id)
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
    ])), scale: .constant(1))
    .environmentObject(TrelloApi.testing)
    .frame(width: 260, height: 800)
  }
}
