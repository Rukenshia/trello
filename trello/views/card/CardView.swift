//
//  CardView.swift
//  trello
//
//  Created by Jan Christophersen on 24.09.22.
//

import SwiftUI
import Combine

struct CardView: View {
  @Environment(\.openWindow) var openWindow
  @EnvironmentObject var trelloApi: TrelloApi
  @EnvironmentObject var preferences: Preferences
  @EnvironmentObject var appState: AppState
  @EnvironmentObject var boardVm: BoardState
  
  @Binding var card: Card
  @State private var showDetails = false
  @State private var popoverState: PopoverState = .none
  @State private var showPopover = false
  @Binding var scale: CGFloat
  
  @State private var isHovering = false
  
  @State private var bgImage: AnyView? = nil
  
  @State private var monitor: Any?;
  
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
  
  private var cardNameForegroundColor: Color {
    guard let cover = card.cover else { return Color(nsColor: .textColor) }
    
    if cover.size != .full {
      return Color(nsColor: .textColor)
    }
    
    if let color = cover.color {
      return Color("CardNameCover_\(color.rawValue)")
    }
    
    return Color(nsColor: .textColor)
  }
  
  private var badgeComponents: AnyView {
    let checkItemsBadge = card.badges.checkItems > 0
    let commentsBadge = card.badges.comments > 0
    let attachmentsBadge = card.badges.attachments > 1 || card.badges.attachments == 1 && card.cover?.idAttachment == nil
    let hasDescription = !card.desc.isEmpty
    
    if checkItemsBadge && commentsBadge && attachmentsBadge {
      return AnyView(HStack(spacing: 1) {
        HStack(spacing: 2) {
          Image(systemName: "checklist")
          Text("\(card.badges.checkItemsChecked)/\(card.badges.checkItems)")
            .foregroundColor(.secondary)
            .lineLimit(1)
            .frame(maxWidth: .infinity)
          
          Image(systemName: "message")
          
          Image(systemName: "paperclip")
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
        .background(Color("CardBackground"))
        .cornerRadius(4)
        
        Text(card.desc)
          .lineLimit(1)
          .foregroundColor(.secondary)
      })
    }
    
    return AnyView(HStack {
      if checkItemsBadge {
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
      if commentsBadge {
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
      if attachmentsBadge {
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
      if hasDescription {
        Text(card.desc)
          .lineLimit(1)
          .foregroundColor(.secondary)
      }
    })
  }
  
  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      if let cover = card.cover {
        if cover.size == .normal {
          CardCoverView(cardId: card.id, cover: cover)
        }
      }
      HStack {
        VStack(alignment: .leading, spacing: 0) {
          
          HStack {
            if displayedLabels.count > 0 {
              ForEach(displayedLabels[0...min(displayedLabels.count - 1, 1)]) { label in
                LabelView(label: label, size: 11 * scale)
              }
              if card.labels.count > 2 {
                Text("+\(card.labels.count - 2)")
                  .font(.system(size: 11 * scale))
              }
            }
          }
          
          HStack {
            if card.closed {
              Image(systemName: "archivebox")
            }
            Text(card.name)
              .multilineTextAlignment(.leading)
              .lineLimit(2)
              .font(.system(size: 12 * scale))
          }
          .foregroundColor(cardNameForegroundColor)
          
          
          HStack {
            CardDueView(cardId: card.id, dueDate: card.dueDate, dueComplete: card.dueComplete, compact: preferences.compactDueDate)
              .font(.system(size: 12 * scale))
            
            badgeComponents
          }
          .font(.system(size: 10 * scale))
          
          CardMembersView(members: boardVm.board.members.filter({ m in card.idMembers.contains(m.id) }))
        }.padding(8 * scale)
        
        Spacer()
      }
    }
    .onHover { hover in
      withAnimation(.easeInOut) {
        self.isHovering = hover
      }
    }
    .frame(alignment: .leading)
    .onTapGesture {
      showDetails = true
    }
    .background(self.bgImage != nil ? self.bgHoverImage! : self.background)
    .sheet(isPresented: $showDetails) {
      CardDetailsView(card: $card, isVisible: $showDetails)
    }
    .popover(isPresented: $showPopover, attachmentAnchor: .point(.bottom), arrowEdge: .bottom) {
      switch (self.popoverState) {
      case .moveToList:
        VStack(spacing: 8) {
          ForEach(self.$boardVm.board.lists.filter{ l in l.id != card.idList}) { list in
            ContextMenuMoveListView(list: list, card: $card)
          }
        }.padding(8)
      case .manageLabels:
        ContextMenuManageLabelsView(labels: self.$boardVm.board.labels, card: $card)
      case .dueDate:
        ContextMenuDueDateView(card: $card)
      case .cardColor:
        ContextMenuCardColorView(card: $card, show: $showPopover)
      case .editCard:
        ContextMenuEditCardView(card: $card, show: $showPopover)
          .padding(8)
          .frame(minWidth: 240)
      case .manageMembers:
        ContextMenuManageMembersView(members: boardVm.board.members.filter{ m in card.idMembers.contains(m.id) }, allMembers: boardVm.board.members, onAdd: { member in
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
    .shadow(color: .black.opacity(0.1), radius: 0, x: 0, y: 1)
    .onAppear {
      monitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { nsevent in
        if !isHovering {
          return nsevent
        }
        
        if appState.creatingCard {
          return nsevent
        }
        
        if showDetails {
          return nsevent
        }
        
        switch (nsevent.characters) {
        case "a":
          self.popoverState = .manageMembers
          showPopover = true
        case "m":
          self.popoverState = .moveToList
          showPopover = true
        case "l":
          self.popoverState = .manageLabels
          showPopover = true
        case "d":
          self.popoverState = .dueDate
          showPopover = true
        case "c":
          self.popoverState = .cardColor
          showPopover = true
        case "e":
          self.popoverState = .editCard
          showPopover = true
        case "r":
          boardVm.updateCard(cardId: card.id, closed: true)
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
      CardView(card: .constant(Card(id: UUID().uuidString, name: "A simple card, for simple people")), scale: .constant(1))
        .frame(width: 280, height: 100)
      CardView(card: .constant(Card(id: UUID().uuidString, labels: [Label(id: "label-id", name: "label name", color: "sky"), Label(id: "duration", name: "duration:15")], name: "A long card name that spans over at least two lines and truncates", desc: "A card desc with pretty long text to check how it behaves", due: TrelloApi.DateFormatter.string(from: Date.now.advanced(by: 100000)))), scale: .constant(1))
        .frame(width: 280, height: 100)
      CardView(card: .constant(Card(id: UUID().uuidString, labels: [Label(id: "label-id", name: "label name", color: "sky"), Label(id: "duration", name: "duration:15")], name: "A long card name that spans over at least two lines and truncates", desc: "A card desc with pretty long text to check how it behaves", due: TrelloApi.DateFormatter.string(from: Date.now.advanced(by: 1000)))), scale: .constant(1))
        .frame(width: 280, height: 100)
      CardView(card: .constant(Card(id: UUID().uuidString, labels: [Label(id: "label-id", name: "label name", color: "sky"), Label(id: "duration", name: "duration:15")], name: "A long card name that spans over at least two lines and truncates", desc: "A card desc with pretty long text to check how it behaves", due: TrelloApi.DateFormatter.string(from: Date.now))), scale: .constant(1))
        .frame(width: 280, height: 100)
      CardView(card: .constant(Card(id: UUID().uuidString, labels: [], name: "Lots of badges", desc: "A card with lots of extra badges", due: TrelloApi.DateFormatter.string(from: Date.now.advanced(by: 50000)), badges: Badges(checkItems: 14, checkItemsChecked: 3, comments: 5, attachments: 2))), scale: .constant(1))
        .frame(width: 260)
    }
    .padding()
    .environmentObject(TrelloApi.testing)
  }
}
