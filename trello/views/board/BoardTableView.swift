//
//  BoardTableView.swift
//  trello
//
//  Created by Jan Christophersen on 26.11.22.
//

import SwiftUI

struct BoardTableLabelsView: View {
  let labels: [Label]
  
  var body: some View {
    HStack {
      if labels.count > 0 {
        ForEach(labels[0...min(labels.count - 1, 1)]) { label in
          LabelView(label: label, size: 11)
        }
        if labels.count > 2 {
          Text("+\(labels.count - 2)")
            .font(.system(size: 10))
        }
      }
    }
    .frame(alignment: .leading)
  }
}

// Needed for the table "value" so that we can sort
private extension Card {
  var dueString: String {
    due ?? "9999" // will break in the year 9999 :(
  }
  
  var idMembersString: String {
    idMembers.joined(separator: ".")
  }
  
  var idLabelsString: String {
    idLabels.joined(separator: ".")
  }
}

struct BoardTableView: View {
  @EnvironmentObject var preferences: Preferences
  @Binding var board: Board
  
  @State private var sortOrder = [KeyPathComparator(\Card.dueString)]
  @State private var selection: Card.ID?
  @State private var showDetails = false
  
  private var cards: [Card] {
    board.cards.sorted(using: sortOrder)
  }
  
  private var due: TableColumn<Card, KeyPathComparator<Card>, some View, Text> {
    TableColumn("Due", value: \.dueString) { card in
      CardDueView(card: Binding(get: { card }, set: { _ in }), compact: preferences.compactDueDate)
        .frame(
          maxWidth: .infinity,
          maxHeight: .infinity,
          alignment: .leading
        )
        .contentShape(Rectangle())
        .onTapGesture(count: 2) {
          selection = card.id
          showDetails = true
        }
        .onTapGesture {
          selection = card.id
        }
    }
  }
  
  private var members: TableColumn<Card, KeyPathComparator<Card>, some View, Text> {
    TableColumn("Assignees", value: \.idMembersString) { card in
      CardMembersView(members: board.members.filter({ m in card.idMembers.contains(m.id) }))
        .frame(
          maxWidth: .infinity,
          maxHeight: .infinity,
          alignment: .leading
        )
        .contentShape(Rectangle())
        .onTapGesture(count: 2) {
          selection = card.id
          showDetails = true
        }
        .onTapGesture {
          selection = card.id
        }
    }
  }
  
  private var labels: TableColumn<Card, KeyPathComparator<Card>, some View, Text> {
    TableColumn("Labels", value: \.idLabelsString) { card in
      BoardTableLabelsView(labels: card.labels)
        .frame(
          maxWidth: .infinity,
          maxHeight: .infinity,
          alignment: .leading
        )
        .contentShape(Rectangle())
        .onTapGesture(count: 2) {
          selection = card.id
          showDetails = true
        }
        .onTapGesture {
          selection = card.id
        }
    }
  }
  
  var body: some View {
    Table(selection: $selection, sortOrder: $sortOrder) {
      TableColumn("Name", value: \.name) { card in
        Text(card.name)
          .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .leading
          )
          .contentShape(Rectangle())
          .onTapGesture(count: 2) {
            selection = card.id
            showDetails = true
          }
          .onTapGesture {
            selection = card.id
          }
      }
      TableColumn("List", value: \.idList) { card in
        Text(board.lists.first(where: { l in l.id == card.idList })!.name)
          .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .leading
          )
          .contentShape(Rectangle())
          .onTapGesture(count: 2) {
            selection = card.id
            showDetails = true
          }
          .onTapGesture {
            selection = card.id
          }
      }
      .width(min: 50, max: 100)
      labels
      members
      due
    } rows: {
      ForEach(cards, content: TableRow.init)
    }
    .sheet(isPresented: $showDetails) {
      CardDetailsView(card: $board.cards.first(where: { c in c.id == selection! })!, isVisible: $showDetails)
    }
  }
}

struct BoardTableView_Previews: PreviewProvider {
  static var previews: some View {
    BoardTableView(board: .constant(Board(id: "id", idOrganization: "orgId", name: "name", prefs: BoardPrefs(), boardStars: [])))
  }
}
