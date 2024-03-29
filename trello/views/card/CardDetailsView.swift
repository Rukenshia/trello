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
  @EnvironmentObject var trelloApi: TrelloApi
  @EnvironmentObject var boardVm: BoardState
  
  @Binding var card: Card
  @State private var loadingComments = true
  @State var comments: [ActionCommentCard] = []
  @State var checklists: [Checklist] = []
  @State var showChecklistForm: Bool = false
  @State var checklistName: String = ""
  
  @State var showMove: Bool = false
  @State var showManageLabels: Bool = false
  @State var showCardCoverMenu: Bool = false
  
  @State var editing: Bool = false
  @State var desc: String = ""
  
  @Binding var isVisible: Bool
  
  var body: some View {
    VStack {
      
      HStack {
        CardNameView(card: self.$card)
        
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
      .padding(8)
      .background(Color("CardBackground"))
      
      ScrollView {
        VStack {
          
          HStack(alignment: .top) {
            VStack(alignment: .leading) {
              if card.labels.count > 0 {
                HStack {
                  ForEach(card.labels) { label in
                    LabelView(label: label, size: 12)
                  }
                }
              }
              
              HStack {
                Image(systemName: "note.text")
                Text("Description")
                  .font(.title2)
                Spacer()
              }
              
              CardDetailsDescriptionView(card: self.$card)
              
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
              
              VStack {
                Divider()
                HStack {
                  Image(systemName: "paperclip")
                  Text("Attachments")
                    .font(.title2)
                  Spacer()
                }
                .padding(4)
                
                CardAttachmentsView(card: self.$card)
              }
              
              VStack {
                Divider()
                HStack {
                  Image(systemName: "message")
                  Text("Comments")
                    .font(.title2)
                  Spacer()
                }
                .padding(4)
                
                AddCommentView(addComment: { text in
                  self.trelloApi.addCardComment(id: self.card.id, text: text) { comment in
                    self.comments.insert(comment, at: 0)
                  }
                })
                
                if loadingComments {
                  ProgressView()
                }
                
                if comments.count > 0 {
                  ForEach(self.comments) { comment in
                    CommentView(comment: comment, onSave: { text in
                      self.trelloApi.updateCardComment(cardId: card.id, commentId: comment.id, text: text) { newComment in
                        if let idx = self.comments.firstIndex(where: { c in c.id == comment.id }) {
                          self.comments[idx].data.text = text
                        }
                      }
                    }, onDelete: {
                      self.trelloApi.deleteCardComment(cardId: card.id, commentId: comment.id) {
                        self.comments.removeAll(where: { c in c.id == comment.id })
                      }
                    }
                    )
                    .padding(.horizontal, 4)
                  }
                }
              }
              .padding(.bottom, 8)
              
              Spacer()
            }
            Spacer()
            VStack(alignment: .leading) {
              HStack {
                Image(systemName: "person")
                Text("Assignee")
                  .font(.title2)
              }
              
              CardDetailsMembersView(members: boardVm.board.members.filter{ m in card.idMembers.contains(m.id) }, allMembers: boardVm.board.members, onAdd: { member in
                self.trelloApi.addMemberToCard(cardId: card.id, memberId: member.id) {
                  card.idMembers.append(member.id)
                }
              }, onRemove: { member in
                self.trelloApi.removeMemberFromCard(cardId: card.id, memberId: member.id) {
                  card.idMembers.removeAll(where: { m in m == member.id })
                }
              })
              
              HStack {
                Image(systemName: "alarm")
                Text("Due date")
                  .font(.title2)
              }
              ContextMenuDueDateView(card: $card)
                .frame(maxWidth: 280)
                .padding(4)
              
              HStack {
                Image(systemName: "hand.tap")
                Text("Actions")
                  .font(.title2)
              }
              
              Button(action: {
                self.showCardCoverMenu = true
              }) { Spacer() }
                .buttonStyle(FlatButton(icon: "rectangle", text: "Cover"))
                .popover(isPresented: self.$showCardCoverMenu, arrowEdge: .bottom) {
                  ContextMenuCardColorView(card: self.card)
                }
              
              
              Button(action: {
                self.showChecklistForm = true
                self.checklistName = "Checklist"
              }) { Spacer() }
                .buttonStyle(FlatButton(icon: "text.badge.checkmark", text: "Add Checklist"))
                .popover(isPresented: $showChecklistForm, arrowEdge: .bottom) {
                  VStack {
                    TextField("Name", text: self.$checklistName)
                    Button(action: {
                      self.trelloApi.createChecklist(name: self.checklistName, cardId: self.card.id) { checklist in
                        self.checklists.append(checklist)
                        self.checklistName = "Checklist"
                        self.showChecklistForm = false
                      }
                    }) {
                      
                    }
                    .buttonStyle(FlatButton(text: "Create"))
                  }
                  .padding(8)
                  .frame(width: 200)
                }
              
              Button(action: {
                self.showManageLabels = true
              }) { Spacer() }
                .buttonStyle(FlatButton(icon: "tag", text: "Labels"))
                .popover(isPresented: $showManageLabels, arrowEdge: .bottom) {
                  ContextMenuManageLabelsView(labels: self.$boardVm.board.labels, card: self.$card)
                    .frame(idealWidth: 180)
                }
              
              Button(action: {
                boardVm.createCard(listId: self.card.idList, sourceCardId: self.card.id)
                self.isVisible = false
              }) { Spacer() }
                .buttonStyle(FlatButton(icon: "doc.on.doc", text: "Copy"))
              
              Button(action: {
                self.showMove = true
              }) { Spacer() }
                .buttonStyle(FlatButton(icon: "rectangle.leadinghalf.inset.filled.arrow.leading", text: "Move"))
                .popover(isPresented: $showMove, arrowEdge: .bottom) {
                  ForEach(self.$boardVm.board.lists.filter{ l in l.id != card.idList}) { list in
                    ContextMenuMoveListView(list: list, card: $card)
                  }
                  .padding()
                }
            }
            .frame(maxWidth: 260)
          }
          .padding(.leading, 4)
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
      }
      .onAppear {
        self.desc = card.desc;
        
        trelloApi.getCardChecklists(id: card.id, completion: { checklists in
          self.checklists = checklists;
        })
        
        trelloApi.getCardComments(id: card.id) { comments in
          self.comments = comments
          self.loadingComments = false
        }
      }
    }
    .frame(idealWidth: 800, idealHeight: (NSApp.windows.first?.contentView?.bounds.height ?? 500) - 120)
  }
}

struct CardDetailsView_Previews: PreviewProvider {
  static var previews: some View {
    CardDetailsView(card: .constant(Card(id: UUID().uuidString, name: "A card", desc: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Quis lectus nulla at volutpat diam ut. Nec dui nunc mattis enim ut tellus elementum sagittis. Dictum fusce ut placerat orci nulla. Lobortis elementum nibh tellus molestie nunc non blandit massa. Facilisis sed odio morbi quis")), isVisible: .constant(true))
      .environmentObject(TrelloApi.testing)
      .environmentObject(BoardState.testing)
      .frame(width: 800, height: 900)
  }
}
