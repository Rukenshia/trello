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
  
  @Binding var card: Card
  let hovering: Bool
  @Binding var showDetails: Bool
  @Binding var popoverState: PopoverState
  @Binding var showPopover: Bool
  
  @State private var bgImage: AnyView? = nil
  
  private var bgHoverImage: AnyView? {
    if let bgImage = self.bgImage {
      if self.hovering {
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
    
    if hovering {
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
        VStack(alignment: .leading, spacing: 0) {
          
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
          }
          
          HStack {
            if card.closed {
              Image(systemName: "archivebox")
            }
            Text(card.name)
              .multilineTextAlignment(.leading)
              .lineLimit(2)
          }
          
          
          HStack {
            CardDueView(card: $card)
              .font(.system(size: 12))
            
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
    //    .onTapGesture(count: 2) {
    //      openWindow(value: card)
    //    }
    .sheet(isPresented: $showDetails) {
      CardDetailsView(card: $card, isVisible: $showDetails)
    }
    .popover(isPresented: $showPopover, attachmentAnchor: .point(.bottom), arrowEdge: .bottom) {
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
    .shadow(color: .black.opacity(0.1), radius: 0, x: 0, y: 1)
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
      CardView(card: .constant(Card(id: UUID().uuidString, name: "A simple card, for simple people")), hovering: false, showDetails: .constant(false), popoverState: .constant(.none), showPopover: .constant(false))
        .frame(width: 280, height: 100)
      CardView(card: .constant(Card(id: UUID().uuidString, labels: [Label(id: "label-id", name: "label name", color: "sky"), Label(id: "duration", name: "duration:15")], name: "A long card name that spans over at least two lines and truncates", desc: "A card desc with pretty long text to check how it behaves", due: TrelloApi.DateFormatter.string(from: Date.now.advanced(by: 100000)))), hovering: true, showDetails: .constant(false), popoverState: .constant(.none), showPopover: .constant(false))
        .frame(width: 280, height: 100)
      CardView(card: .constant(Card(id: UUID().uuidString, labels: [Label(id: "label-id", name: "label name", color: "sky"), Label(id: "duration", name: "duration:15")], name: "A long card name that spans over at least two lines and truncates", desc: "A card desc with pretty long text to check how it behaves", due: TrelloApi.DateFormatter.string(from: Date.now.advanced(by: 1000)))), hovering: false, showDetails: .constant(false), popoverState: .constant(.none), showPopover: .constant(false))
        .frame(width: 280, height: 100)
      CardView(card: .constant(Card(id: UUID().uuidString, labels: [Label(id: "label-id", name: "label name", color: "sky"), Label(id: "duration", name: "duration:15")], name: "A long card name that spans over at least two lines and truncates", desc: "A card desc with pretty long text to check how it behaves", due: TrelloApi.DateFormatter.string(from: Date.now))), hovering: false, showDetails: .constant(false), popoverState: .constant(.none), showPopover: .constant(false))
        .frame(width: 280, height: 100)
    }
    .padding()
    .environmentObject(TrelloApi(key: Preferences().trelloKey!, token: Preferences().trelloToken!))
  }
}
