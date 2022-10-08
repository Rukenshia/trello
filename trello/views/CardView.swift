//
//  CardView.swift
//  trello
//
//  Created by Jan Christophersen on 24.09.22.
//

import SwiftUI
import Combine

struct CardView: View {
    @EnvironmentObject var trelloApi: TrelloApi;
    
    @Binding var card: Card;
    
    @State private var color: Color;
    @State private var showDetails: Bool;
    
    @State private var dueColor: Color;
    
    @State private var isHovering: Bool;
    
    private let dateFormatter: DateFormatter;
    private let timeFormatter: DateFormatter;
    
    private let timer: Publishers.Autoconnect<Timer.TimerPublisher>;
    
    init(card: Binding<Card>) {
        self._isHovering = State(initialValue: false);
        self._card = card
        self._color = State(initialValue: Color("CardBg").opacity(0.9))
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
        
        self._dueColor = State(initialValue: self.getDueColor(now: Date.now))
    }
    
    
    private var formattedDueDate: String {
        dateFormatter.string(from: card.dueDate!).uppercased()
    }
    
    private var formattedDueTime: String {
        timeFormatter.string(from: card.dueDate!).uppercased()
    }
    
    private func getDueColor(now: Date) -> Color {
        guard let due = card.dueDate else {
            return Color.clear;
        }
        
        if card.dueComplete {
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
        card.labels.filter { label in label.color != nil }
    }
    
    private var duration: String? {
        guard let label = card.labels.first(where: { l in l.name.starts(with: "duration:") }) else {
            return nil
        }
        
        return label.name.replacingOccurrences(of: "duration:", with: "")
    }
    
    var body: some View {
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
                    if hover {
                        self.color = Color("CardBg")
                        
                        self.dueColor = self.getDueColor(now: Date.now)
                        NSCursor.pointingHand.push()
                    } else {
                        self.color = Color("CardBg").opacity(0.9)
                        
                        self.dueColor = self.getDueColor(now: Date.now)
                        NSCursor.pop()
                    }
                }
            })
            .onTapGesture {
                showDetails = true
            }
            .sheet(isPresented: $showDetails) {
                CardDetailsView(card: card, isVisible: $showDetails)
            }
            .onReceive(timer) { newTime in
                self.dueColor = self.getDueColor(now: newTime)
            }
            .onAppear {
                self.dueColor = self.getDueColor(now: Date.now)
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

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(card: .constant(Card(id: UUID().uuidString, name: "Test card", desc: "A card desc with pretty long text to check how it behaves", due: TrelloApi.DateFormatter.string(from: Date.now))))
            .frame(width: 280)
    }
}
