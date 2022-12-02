//
//  CardView.swift
//  trello
//
//  Created by Jan Christophersen on 24.09.22.
//

import SwiftUI
import Combine

enum PopoverState {
  case none;
  
  case moveToList;
  case manageLabels;
  case dueDate;
  case cardColor;
  case editCard;
  case manageMembers
}

struct CardView: View {
  @Environment(\.openWindow) var openWindow
  @EnvironmentObject var trelloApi: TrelloApi;
  
  @Binding var card: Card;
  
  @State private var showDetails: Bool = false;
  
  @State private var isHovering: Bool = false;
  
  @State private var monitor: Any?;
  @State private var showPopover: Bool = false;
  @State private var popoverState: PopoverState = .none;
  
  @State private var bgImage: AnyView? = nil
  
  private var bgHoverImage: AnyView? {
    if let bgImage = self.bgImage {
      if self.isHovering {
        return AnyView(bgImage.brightness(0.1))
      }
      
      return bgImage
    }
    
    return nil
  }
  
  private var background: AnyView {
    var cardBg: Color = Color("CardBackground")
    
    if let cover = card.cover {
      if cover.color != nil {
        if cover.size == .full {
          cardBg = cover.displayColor
        }
      }
    }
    
    if isHovering {
      return AnyView(cardBg.brightness(0.1))
    }
    
    return AnyView(cardBg.opacity(0.95))
  }
  
  private var displayedLabels: [Label] {
    card.labels.filter { label in label.color != nil && !label.name.contains("color:") }
  }
  
  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      if let cover = card.cover {
        if cover.size == .normal {
          CardCoverView(cardId: card.id, cover: cover)
        }
      }
      HStack {
        VStack(alignment: .leading, spacing: 2) {
          
          HStack {
            if displayedLabels.count > 0 {
              ForEach(displayedLabels[0...min(displayedLabels.count - 1, 1)]) { label in
                LabelView(label: label, size: 11)
              }
              if card.labels.count > 2 {
                Text("+\(card.labels.count - 2)")
                  .font(.system(size: 11))
              }
            }
            Spacer()
            CardDueView(card: $card)
          }
          
          Text(card.name)
            .font(.system(size: 13.25))
            .multilineTextAlignment(.leading)
            .lineLimit(2)
          
          
          HStack {
            if card.badges.checkItems > 0 {
              HStack(spacing: 1) {
                Image(systemName: "checklist")
                Text("\(card.badges.checkItemsChecked)/\(card.badges.checkItems)")
                  .foregroundColor(.secondary)
              }
              .padding(.horizontal, 4)
              .padding(.vertical, 2)
              .background(Color("CardBackground"))
              .cornerRadius(4)
            }
            if card.badges.comments > 0 {
              HStack(spacing: 1) {
                Image(systemName: "message")
                Text("\(card.badges.comments)")
                  .foregroundColor(.secondary)
              }
              .padding(.horizontal, 4)
              .padding(.vertical, 2)
              .background(Color("CardBackground"))
              .cornerRadius(4)
            }
            if card.badges.attachments > 1 || card.badges.attachments == 1 && card.cover?.idAttachment == nil {
              HStack(spacing: 1) {
                Image(systemName: "paperclip")
                Text("\(card.badges.attachments)")
                  .foregroundColor(.secondary)
              }
              .padding(.horizontal, 4)
              .padding(.vertical, 2)
              .background(Color("CardBackground"))
              .cornerRadius(4)
            }
            if !card.desc.isEmpty {
              Text(card.desc)
                .lineLimit(1)
                .foregroundColor(.secondary)
            }
          }
          .font(.system(size: 10))
          
          CardMembersView(members: trelloApi.board.members.filter({ m in card.idMembers.contains(m.id) }))
        }.padding(8)
        
        Spacer()
      }
    }
    .frame(alignment: .leading)
    .background(self.bgImage != nil ? self.bgHoverImage! : self.background)
    .onHover(perform: {hover in
      self.isHovering = hover
      withAnimation(.easeInOut(duration: 0.1)) {
        if hover {
          NSCursor.pointingHand.push()
        } else {
          NSCursor.pop()
        }
      }
    })
//    .onTapGesture(count: 2) {
//      openWindow(value: card)
//    }
    .onTapGesture {
      showDetails = true
    }
    .sheet(isPresented: $showDetails) {
      CardDetailsView(card: $card, isVisible: $showDetails)
    }
    .onAppear {
      monitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { nsevent in
        if !isHovering {
          return nsevent
        }
        
        if self.showPopover {
          return nsevent
        }
        
        if self.showDetails {
          return nsevent
        }
        
        switch (nsevent.characters) {
        case "a":
          self.popoverState = .manageMembers
          self.showPopover = true
        case "m":
          self.popoverState = .moveToList
          self.showPopover = true
        case "l":
          self.popoverState = .manageLabels
          self.showPopover = true
        case "d":
          self.popoverState = .dueDate
          self.showPopover = true
        case "c":
          self.popoverState = .cardColor
          self.showPopover = true
        case "e":
          self.popoverState = .editCard
          self.showPopover = true
        default:
          ()
        }
        
        return nsevent
      }
    }
    .onDisappear {
      if let monitor = self.monitor {
        NSEvent.removeMonitor(monitor)
      }
    }
    .popover(isPresented: self.$showPopover, attachmentAnchor: .point(.bottom), arrowEdge: .bottom) {
      switch (self.popoverState) {
      case .moveToList:
        VStack(spacing: 8) {
          ForEach(self.$trelloApi.board.lists.filter{ l in l.id != card.idList}) { list in
            ContextMenuMoveListView(list: list, card: $card)
          }
        }.padding(8)
      case .manageLabels:
        ContextMenuManageLabelsView(labels: self.$trelloApi.board.labels, card: $card)
      case .dueDate:
        ContextMenuDueDateView(card: $card)
      case .cardColor:
        ContextMenuCardColorView(card: $card, show: $showPopover)
      case .editCard:
        ContextMenuEditCardView(card: $card, show: $showPopover)
          .padding(8)
          .frame(minWidth: 240)
      case .manageMembers:
        ContextMenuManageMembersView(members: trelloApi.board.members.filter{ m in card.idMembers.contains(m.id) }, allMembers: trelloApi.board.members, onAdd: { member in
          self.trelloApi.addMemberToCard(cardId: card.id, memberId: member.id) {
            card.idMembers.append(member.id)
          }
        }, onRemove: { member in
          self.trelloApi.removeMemberFromCard(cardId: card.id, memberId: member.id) {
            card.idMembers.removeAll(where: { m in m == member.id })
          }
        })
      default:
        EmptyView()
      }
    }
    .cornerRadius(4)
    .shadow(color: .black.opacity(0.2), radius: 3, x: 4, y: 4)
    .task {
      if let cover = card.cover {
        if cover.size == .full {
          if let idAttachment = cover.idAttachment {
            trelloApi.getCardAttachment(cardId: card.id, attachmentId: idAttachment) { attachment in
              trelloApi.downloadAttachment(url: attachment.previews.last!.url, completion: { data in
                guard let nsImage = NSImage(data: data) else { return }
                self.bgImage = AnyView(Image(nsImage: nsImage).resizable().scaledToFill())
              })
            }
          }
        }
      }
    }
  }
}

struct CardView_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      CardView(card: .constant(Card(id: UUID().uuidString, name: "A simple card, for simple people")))
        .frame(width: 280, height: 100)
      CardView(card: .constant(Card(id: UUID().uuidString, labels: [Label(id: "label-id", name: "label name", color: "sky"), Label(id: "duration", name: "duration:15")], name: "A long card name that spans over at least two lines and truncates", desc: "A card desc with pretty long text to check how it behaves", due: TrelloApi.DateFormatter.string(from: Date.now.advanced(by: 100000)))))
        .frame(width: 280, height: 100)
      CardView(card: .constant(Card(id: UUID().uuidString, labels: [Label(id: "label-id", name: "label name", color: "sky"), Label(id: "duration", name: "duration:15")], name: "A long card name that spans over at least two lines and truncates", desc: "A card desc with pretty long text to check how it behaves", due: TrelloApi.DateFormatter.string(from: Date.now.advanced(by: 1000)))))
        .frame(width: 280, height: 100)
      CardView(card: .constant(Card(id: UUID().uuidString, labels: [Label(id: "label-id", name: "label name", color: "sky"), Label(id: "duration", name: "duration:15")], name: "A long card name that spans over at least two lines and truncates", desc: "A card desc with pretty long text to check how it behaves", due: TrelloApi.DateFormatter.string(from: Date.now))))
        .frame(width: 280, height: 100)
    }
    .padding()
    .environmentObject(TrelloApi(key: Preferences().trelloKey!, token: Preferences().trelloToken!))
  }
}
