//
//  CardDetailsView.swift
//  trello
//
//  Created by Jan Christophersen on 24.09.22.
//

import SwiftUI
import SwiftDown
import Combine

struct CardDetailsView: View {
    @EnvironmentObject var trelloApi: TrelloApi;
    
    @Binding var card: Card;
    @State var checklists: [Checklist] = [];
    
    @State var editing: Bool = false;
    @State var desc: String = "";
    
    @Binding var isVisible: Bool;
    
    var body: some View {
        
        VStack {
            HStack {
                Text(card.name)
                    .font(.title)
                Spacer()
                Button(action: {
                    isVisible = false;
                }) {
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                            .imageScale(.large)
                    }
                }
                .keyboardShortcut(.cancelAction)
                .buttonStyle(PlainButtonStyle())
            }
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Divider()
                    if card.labels.count > 0 {
                        HStack {
                            ForEach(card.labels) { label in
                                LabelView(label: label)
                            }
                        }
                    }
                    
                    HStack {
                        Image(systemName: "note.text")
                        Text("Description")
                            .font(.title2)
                        Spacer()
                    }
                    
                    if self.editing {
                        SwiftDownEditor(text: $desc)
                            .insetsSize(4)
                            .theme(Theme.BuiltIn.defaultDark.theme())
                            .frame(minWidth: 400, minHeight: 120, maxHeight: .infinity)
                        
                        Button(action: {
                            self.editing = false;
                            
                            self.trelloApi.setCardDesc(card: card, desc: self.desc, completion: { newCard in
                                print("description updated")
                            })
                        }) {
                            Text("Save changes")
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color("CardBg"))
                                .cornerRadius(4)
                        }
                        .buttonStyle(.plain)
                    } else {
                        SwiftDownEditor(text: $desc)
                            .insetsSize(4)
                            .isEditable(false)
                            .theme(Theme.BuiltIn.defaultDark.theme())
                            .frame(minWidth: 400, minHeight: 120, maxHeight: .infinity)
                        
                        Button(action: {
                            self.editing = true;
                        }) {
                            Text("Edit")
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color("CardBg"))
                                .cornerRadius(4)
                        }
                        .buttonStyle(.plain)
                        
                    }
                    
                    if checklists.count > 0 {
                        Divider()
                        HStack {
                            Image(systemName: "checklist")
                            Text("Checklists")
                                .font(.title2)
                            Spacer()
                        }
                        .padding(4)
                        ForEach(self.$checklists) { checklist in
                            ChecklistView(checklist: checklist)
                                .padding(.horizontal, 4)
                        }
                        .padding(.bottom, 8)
                    }
                }
                Spacer()
                VStack(alignment: .leading) {
                    ContextMenuDueDateView(card: $card)
                        .frame(maxWidth: 180)
                }
            }
        }
        .onAppear {
            self.desc = card.desc;
            
            trelloApi.getCardChecklists(id: card.id, completion: { checklists in
                self.checklists = checklists;
            })
        }
        .padding(24)
        .padding(.vertical, 36)
    }
}

struct CardDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        CardDetailsView(card: .constant(Card(id: UUID().uuidString, name: "A card", desc: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Quis lectus nulla at volutpat diam ut. Nec dui nunc mattis enim ut tellus elementum sagittis. Dictum fusce ut placerat orci nulla. Lobortis elementum nibh tellus molestie nunc non blandit massa. Facilisis sed odio morbi quis commodo odio aenean sed adipiscing. Sapien et ligula ullamcorper malesuada. Nunc sed id semper risus in hendrerit. In vitae turpis massa sed elementum tempus egestas sed. Etiam sit amet nisl purus. Et odio pellentesque diam volutpat commodo sed.\n\nTurpis cursus in hac habitasse platea. Sapien faucibus et molestie ac. Risus nec feugiat in fermentum. Pellentesque elit ullamcorper dignissim cras. Ut eu sem integer vitae justo eget magna. Tincidunt nunc pulvinar sapien et ligula. Vitae tortor condimentum lacinia quis vel eros donec ac odio. Ac placerat vestibulum lectus mauris ultrices eros in cursus. Commodo ullamcorper a lacus vestibulum sed arcu non odio euismod. Non curabitur gravida arcu ac tortor dignissim. Viverra adipiscing at in tellus integer feugiat scelerisque. Blandit volutpat maecenas volutpat blandit aliquam etiam. Faucibus a pellentesque sit amet porttitor eget. Potenti nullam ac tortor vitae purus faucibus ornare suspendisse sed.")), isVisible: .constant(true))
    }
}
