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

struct SizePreferenceKey: PreferenceKey {
  static var defaultValue: CGSize = .zero
  
  static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
    value = nextValue()
  }
}

struct SizeModifier: ViewModifier {
  private var sizeView: some View {
    GeometryReader { geometry in
      Color.clear.preference(key: SizePreferenceKey.self, value: geometry.size)
    }
  }
  
  func body(content: Content) -> some View {
    content.overlay(sizeView)
  }
}

extension View {
  func getSize(perform: @escaping (CGSize) -> ()) -> some View {
    self
      .modifier(SizeModifier())
      .onPreferenceChange(SizePreferenceKey.self) {
        perform($0)
      }
  }
}

struct TrelloListView: View {
  @EnvironmentObject var trelloApi: TrelloApi
  @EnvironmentObject var appState: AppState
  @EnvironmentObject var boardVm: BoardState
  
  @Binding var list: List
  @Binding var scale: CGFloat
  
  @State private var addCardColor: Color = Color(.clear)
  @State private var showAddCard: Bool = false
  
  @State private var showMenu: Bool = false
  
  @State private var width: CGFloat = 150
  
  @State private var scrollViewContentSize: CGSize = .zero
  
  var background: Color {
    return Color("ListBackground").opacity(0.95)
  }
  
  var body: some View {
    VStack(spacing: 4) {
      HStack {
        TrelloListNameView(listId: list.id, name: list.name, onRename: { newName in
          boardVm.setListName(listId: list.id, name: newName)
        })
        .font(.system(size: 12 * scale))
        .fontWeight(.medium)
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
      GeometryReader { proxy in
        ScrollView {
          // FIXME: will be very slow with many cards, should use LazyVStack or something but that feels laggier most of the time
          VStack(spacing: 4) {
            ForEach(self.$list.cards, id: \.id) { card in
              CardView(card: card,
                       scale: $scale)
              .onDrag {
                boardVm.draggedCard = card.wrappedValue
                boardVm.stopUpdating()
                return NSItemProvider(object: card.id as NSString)
              }
              .onDrop(of: ["public.text"], delegate: CardDropDelegate(trelloApi: self.trelloApi, boardVm: boardVm, card: card, list: self.$list))
              .gesture(
                DragGesture()
                  .onEnded { value in
                    if boardVm.draggedCard != nil {
                      boardVm.draggedCard = nil
                      boardVm.startUpdating()
                    }
                  }
              )
            }
          }
          .background(
            GeometryReader { geo -> Color in
              DispatchQueue.main.async {
                scrollViewContentSize = geo.size
              }
              return Color.clear
            }
          )
        }
        .scrollIndicators(.never) // FIXME: with the scroll indicators visible, there's always some white background
      }
      .frame(
        maxHeight: scrollViewContentSize.height + 2
      )
      
      
      if showAddCard {
        AddCardView(list: self.list, showAddCard: self.$showAddCard, onFocusLost: {
          showAddCard = false
        })
      }
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
        .font(.system(size: 12 * scale))
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
    .onDrop(of: ["public.text"], delegate: CardDropDelegate(trelloApi: self.trelloApi, boardVm: boardVm, card: Binding.constant(Card.empty), list: self.$list))
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
    .cornerRadius(8)
    .frame(idealWidth:width)
  }
  
  private func setWidth() {
    self.width = self.list.cards.count > 0 || showAddCard ? 260 * scale : 150 * scale
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
