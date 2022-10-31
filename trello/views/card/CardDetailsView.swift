//
//  CardDetailsView.swift
//  trello
//
//  Created by Jan Christophersen on 24.09.22.
//

import SwiftUI
import Combine
import MarkdownUI

struct CardDetailsView: View {
    @EnvironmentObject var trelloApi: TrelloApi;
    
    @Binding var card: Card;
    @State var checklists: [Checklist] = [];
    @State var showChecklistForm: Bool = false;
    @State var checklistName: String = "";
    
    @FocusState private var focusedField: String?
    @State var editingTitle: Bool = false
    @State var newTitle: String = ""
    
    @State var editing: Bool = false;
    @State var desc: String = "";
    
    @Binding var isVisible: Bool;
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    HStack {
                        if self.editingTitle {
                            Button(action: self.updateTitle) {
                                
                            }
                            .buttonStyle(IconButton(icon: "checkmark", size: 16))
                            TextField("Card name", text: $newTitle, onCommit: self.updateTitle)
                                .textFieldStyle(.plain)
                                .focused($focusedField, equals: "name")
                        } else {
                            Button(action: {
                                self.editingTitle = true
                                self.focusedField = "name"
                                self.newTitle = card.name
                            }) {
                                
                            }
                            .buttonStyle(IconButton(icon: "square.and.pencil", size: 16))
                            Text(card.name)
                        }
                        Spacer()
                    }
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
                            TextEditor(text: $desc)
                            
                            Button(action: {
                                self.editing = false;
                                
                                self.trelloApi.setCardDesc(card: card, desc: self.desc, completion: { newCard in
                                    print("description updated")
                                })
                            }) {
                                Text("Save changes")
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color("TwZinc700"))
                                    .cornerRadius(4)
                            }
                            .buttonStyle(.plain)
                        } else {
                            Markdown(self.desc)
                            
                            Button(action: {
                                self.editing = true;
                            }) {
                                Text("Edit")
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color("TwZinc700"))
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
                                ChecklistView(checklist: checklist, onDelete: {
                                    self.checklists = self.checklists.filter{ c in c.id != checklist.id }
                                })
                                    .padding(.horizontal, 4)
                            }
                            .padding(.bottom, 8)
                        }
                        Spacer()
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: "alarm")
                            Text("Due date")
                                .font(.title2)
                        }
                        ContextMenuDueDateView(card: $card)
                            .frame(maxWidth: 180)
                            .padding(4)
                        
                        HStack {
                            Image(systemName: "hand.tap")
                            Text("Actions")
                                .font(.title2)
                        }
                        
                        
                        Button(action: {
                            self.showChecklistForm = true
                        }) { }
                            .buttonStyle(FlatButton(icon: "text.badge.checkmark", text: "Add Checklist"))
                            .popover(isPresented: $showChecklistForm, arrowEdge: .bottom) {
                                VStack {
                                    TextField("Name", text: self.$checklistName)
                                    Button(action: {
                                        self.trelloApi.createChecklist(name: self.checklistName, cardId: self.card.id) { checklist in
                                            self.checklists.append(checklist)
                                            self.checklistName = ""
                                            self.showChecklistForm = false
                                        }
                                    }) {
                                        
                                    }
                                    .buttonStyle(FlatButton(text: "Create"))
                                }
                                .padding(8)
                                .frame(width: 200)
                            }
                    }
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
        .padding(.vertical, self.checklists.count > 0 ? 16 : 0)
        .frame(idealWidth: (NSApp.keyWindow?.contentView?.bounds.width ?? 500) - 120, idealHeight: (NSApp.keyWindow?.contentView?.bounds.height ?? 500) - 120)
    }
    
    private func updateTitle() {
        self.editingTitle = false
        
        self.trelloApi.setCardName(card: self.card, name: self.newTitle) { newCard in
            
        }
    }
}

struct CardDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        CardDetailsView(card: .constant(Card(id: UUID().uuidString, name: "A card", desc: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Quis lectus nulla at volutpat diam ut. Nec dui nunc mattis enim ut tellus elementum sagittis. Dictum fusce ut placerat orci nulla. Lobortis elementum nibh tellus molestie nunc non blandit massa. Facilisis sed odio morbi quis commodo odio aenean sed adipiscing. Sapien et ligula ullamcorper malesuada. Nunc sed id semper risus in hendrerit. In vitae turpis massa sed elementum tempus egestas sed. Etiam sit amet nisl purus. Et odio pellentesque diam volutpat commodo sed.\n\nTurpis cursus in hac habitasse platea. Sapien faucibus et molestie ac. Risus nec feugiat in fermentum. Pellentesque elit ullamcorper dignissim cras. Ut eu sem integer vitae justo eget magna. Tincidunt nunc pulvinar sapien et ligula. Vitae tortor condimentum lacinia quis vel eros donec ac odio. Ac placerat vestibulum lectus mauris ultrices eros in cursus. Commodo ullamcorper a lacus vestibulum sed arcu non odio euismod. Non curabitur gravida arcu ac tortor dignissim. Viverra adipiscing at in tellus integer feugiat scelerisque. Blandit volutpat maecenas volutpat blandit aliquam etiam. Faucibus a pellentesque sit amet porttitor eget. Potenti nullam ac tortor vitae purus faucibus ornare suspendisse sed.")), isVisible: .constant(true))
            .environmentObject(TrelloApi(key: "", token: ""))
    }
}
