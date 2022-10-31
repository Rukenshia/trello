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
}

struct CardView: View {
    @EnvironmentObject var trelloApi: TrelloApi;
    
    @Binding var card: Card;
    
    @State private var showDetails: Bool = false;
    
    @State private var isHovering: Bool = false;
    
    @State private var monitor: Any?;
    @State private var showPopover: Bool = false;
    @State private var popoverState: PopoverState = .none;
    
    private var color: AnyView {
        var cardBg: Color = Color("TwZinc700")
        
        if let label = self.card.labels.first(where: { label in label.name.contains("color:") }) {
            cardBg = Color("CardBg_\(label.name.split(separator: ":")[1])");
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
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    Text(card.name)
                        .bold()
                        .font(.system(size: 14))
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                        .foregroundColor(.white)
                    
                    HStack{
                        if displayedLabels.count > 0 {
                            ForEach(displayedLabels[0...min(displayedLabels.count - 1, 1)]) { label in
                                LabelView(label: label)
                            }
                            if card.labels.count > 2 {
                                Text("+\(card.labels.count - 2)")
                                    .font(.system(size: 10))
                            }
                        }
                    }
                    
                    
                    HStack {
                        if card.badges.checkItems > 0 {
                            HStack(spacing: 1) {
                                Image(systemName: "checklist")
                                Text("\(card.badges.checkItemsChecked)/\(card.badges.checkItems)")
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(Color("TwZinc700"))
                            .cornerRadius(4)
                        }
                        Text(card.desc)
                            .lineLimit(1)
                            .foregroundColor(.secondary)
                    }
                }.padding()
                Spacer()
                
                if card.due != nil {
                    CardDueView(card: $card)
                }
            }
        }
        .frame(alignment: .leading)
        .background(self.color)
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
                case "D":
                    self.trelloApi.markAsDone(card: card, completion: { newCard in
                        trelloApi.objectWillChange.send()
                        card.idLabels = newCard.idLabels
                        card = newCard
                    }, after_timeout: {
                        print("after_timeout")
                    })
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
                ContextMenuCardColorView(labels: self.$trelloApi.board.labels, card: $card, show: $showPopover)
            default:
                EmptyView()
            }
        }
        .cornerRadius(4)
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(card: .constant(Card(id: UUID().uuidString, name: "Test card", desc: "A card desc with pretty long text to check how it behaves", due: TrelloApi.DateFormatter.string(from: Date.now))))
            .frame(width: 280)
    }
}