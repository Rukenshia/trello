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
    
    @State private var color: AnyView;
    @State private var showDetails: Bool;
    
    @State private var due: Date?;
    @State private var dueComplete: Bool = false;
    @State private var dueColor: Color;
    
    @State private var isHovering: Bool;
    
    @State private var monitor: Any?;
    @State private var showPopover: Bool = false;
    @State private var popoverState: PopoverState = .none;
    
    private let dateFormatter: DateFormatter;
    private let timeFormatter: DateFormatter;
    
    private let timer: Publishers.Autoconnect<Timer.TimerPublisher>;
    
    init(card: Binding<Card>) {
        self._isHovering = State(initialValue: false);
        self._card = card
        self._color = State(initialValue: AnyView(Color("CardBg").opacity(0.9)))
        self._showDetails = State(initialValue: false)
        
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = "MMM dd"
        
        self.timeFormatter = DateFormatter()
        self.timeFormatter.dateFormat = "HH:mm"
        
        self._dueColor = State(initialValue: .clear)
        
        self.timer = Timer.publish(
            every: 5, // second
            on: .main,
            in: .common
        ).autoconnect();
        
        self.dueComplete = card.wrappedValue.dueComplete;
        self.due = card.wrappedValue.dueDate;
        self._dueColor = State(initialValue: self.getDueColor(now: Date.now));
        self._color = State(initialValue: AnyView(self.getColor().opacity(0.95)));
    }
    
    
    private var formattedDueDate: String {
        dateFormatter.string(from: card.dueDate!).uppercased()
    }
    
    private var formattedDueTime: String {
        timeFormatter.string(from: card.dueDate!).uppercased()
    }
    
    private func getColor() -> Color {
        if let label = card.labels.first(where: { label in label.name.contains("color:") }) {
            return Color("CardBg_\(label.name.split(separator: ":")[1])");
        }
        
        return Color("CardBg");
    }
    
    private func getDueColor(now: Date) -> Color {
        guard let due = self.due else {
            return Color.clear;
        }
        
        if self.dueComplete {
            return isHovering ? Color("CardDueCompleteBg") : Color("CardDueCompleteBg").opacity(0.85);
        }
        
        if now > due {
            return isHovering ? Color("CardOverdueBg") : Color("CardOverdueBg").opacity(0.85);
        }
        
        let diff = Calendar.current.dateComponents([.day], from: now, to: due);
        
        if diff.day! > 0 {
            return Color.clear;
        }
        
        return isHovering ? Color("CardDueSoonBg") : Color("CardDueSoonBg").opacity(0.85);
    }
    
    private var displayedLabels: [Label] {
        card.labels.filter { label in label.color != nil && !label.name.contains("color:") }
    }
    
    private var duration: String? {
        guard let label = card.labels.first(where: { l in l.name.starts(with: "duration:") }) else {
            return nil
        }
        
        return label.name.replacingOccurrences(of: "duration:", with: "")
    }
    
    var body: some View {
        HStack {
            // TODO: Ideally the whole card should be draggable, but for some reason I couldn't figure
            //       out it does not work because of the .onTapGesture handler,
            //       so now there's a "dot" you can drag from.
            Circle().fill(Color("CardBg")).frame(width: 8, height: 8).opacity(1)
            ZStack {
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
                            
                            Text(card.desc)
                                .lineLimit(1)
                                .foregroundColor(.secondary)
                        }.padding()
                        Spacer()
                        
                        if card.due != nil {
                            if isHovering {
                                VStack {
                                    Spacer()
                                    Button(action: {
                                        self.trelloApi.markAsDone(card: card, completion: { newCard in
                                            trelloApi.objectWillChange.send()
                                            card.idLabels = newCard.idLabels
                                            card = newCard
                                            print(newCard)
                                        }, after_timeout: {
                                            print("after_timeout")
                                        })
                                    }) {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(Color("LabelFg_green"))
                                    }
                                    .font(.system(size: 14))
                                    .cornerRadius(4)
                                    .buttonStyle(.plain)
                                    Spacer()
                                }
                                .padding(4)
                                .padding(.horizontal, 16)
                                .background(Color("LabelBg_green"))
                                .frame(maxHeight: .infinity)
                            } else {
                                VStack {
                                    Text(formattedDueDate)
                                    Text(formattedDueTime)
                                    if let duration {
                                        HStack(spacing: 0) {
                                            Image(systemName: "clock")
                                            Text(duration)
                                        }
                                        .padding(.top, 2)
                                    }
                                }
                                .font(.system(size: 10, weight: .bold))
                                .padding(4)
                                .padding(.horizontal, 6)
                                .frame(maxHeight: .infinity)
                                .background(dueColor)
                            }
                        }
                    }
                }
                .frame(alignment: .leading)
                .background(self.color)
                .onHover(perform: {hover in
                    self.isHovering = hover
                    withAnimation(.easeInOut(duration: 0.1)) {
                        // TODO: fix hover with AnyView
                        
                        if hover {
                            self.color = AnyView(self.getColor().brightness(0.1));
                            
                            self.dueColor = self.getDueColor(now: Date.now)
                            NSCursor.pointingHand.push()
                        } else {
                            self.color = AnyView(self.getColor().opacity(0.95));
                            
                            self.dueColor = self.getDueColor(now: Date.now)
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
                .onReceive(Just(card)) { newCard in
                    self.due = newCard.dueDate
                    self.dueComplete = newCard.dueComplete
                }
                .onReceive(timer) { newTime in
                    self.dueColor = self.getDueColor(now: newTime)
                }
                .onAppear {
                    self.dueColor = self.getDueColor(now: Date.now)
                    
                    //                    print("ON APPEAR \(card.name)")
                    //                    let cardName = card.name
                    monitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { nsevent in
                        //                        print("KEYPRESS HANDLER: ", cardName)
                        if !isHovering {
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
                        ContextMenuCardColorView(labels: self.$trelloApi.board.labels, card: $card)
                    default:
                        EmptyView()
                    }
                }
                
                
                //            if isHovering {
                //                HStack {
                //                    Spacer()
                //                    VStack {
                //                        Spacer()
                //                        Button(action: {
                //                            print("DONE STUFF")
                //                        }) {
                //                            Image(systemName: "checkmark")
                //                                .foregroundColor(Color("LabelFg_green"))
                //                            Text("done")
                //                        }
                //                        .font(.system(size: 14))
                //                        .cornerRadius(4)
                //                        .buttonStyle(.plain)
                //                        Spacer()
                //                    }
                //                    .frame(alignment: .trailing)
                //                    .padding(8)
                //                    .background(Color.black.opacity(0.5))
                //                    .frame(maxWidth: .infinity)
                //                }
                //                .frame(maxWidth: .infinity, maxHeight: .infinity)
                //            }
            }
            .cornerRadius(4)
        }
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(card: .constant(Card(id: UUID().uuidString, name: "Test card", desc: "A card desc with pretty long text to check how it behaves", due: TrelloApi.DateFormatter.string(from: Date.now))))
            .frame(width: 280)
    }
}
