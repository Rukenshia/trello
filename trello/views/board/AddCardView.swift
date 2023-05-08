//
//  AddCardView.swift
//  trello
//
//  Created by Jan Christophersen on 10.10.22.
//

import SwiftUI
import AppKit

struct AddCardView: View {
  @EnvironmentObject var trelloApi: TrelloApi
  @Binding var list: List
  @Binding var showAddCard: Bool
  
  @State private var name: String = ""
  @State private var debouncedCreate: (() -> Void) = {}
  
  enum FocusField: Hashable {
    case name
  }
  
  @FocusState private var focusedField: FocusField?
  

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      HStack(alignment: .top, spacing: 0) {
        TextEditor(text: $name)
          .scrollIndicators(.never)
          .padding(2)
          .lineLimit(2)
          .focused($focusedField, equals: .name)
          .textFieldStyle(.plain)
          .scrollContentBackground(.hidden)
          .onSubmit {
            self.trelloApi.createCard(list: self.list, name: self.name, description: "") { card in
              print("card \(card.name) created")
              
              self.showAddCard = false
            }
          }
          .overlay {
            if name.isEmpty {
              VStack {
                HStack {
                  Text("Start typing and press return to add card")
                    .padding(.leading, 5)
                    .foregroundColor(Color(.secondaryLabelColor))
                    .frame(alignment: .leading)
                    .lineLimit(2)
                    .scrollIndicators(.hidden)
                  Spacer()
                }
                Spacer()
              }
              .allowsHitTesting(false)
            }
          }
          .onChange(of: name) { newName in
            if newName.hasSuffix("\n") {
              debouncedCreate()
            }
          }
      }
    }
    .padding(6)
    .background(Color("CardBackground"))
    .cornerRadius(4)
    .frame(height: 40)
    .onAppear {
      debouncedCreate = debounce(interval: 0.5) {
        create(name)
      }
      
      DispatchQueue.main.async {
        focusedField = .name
      }
    }
  }
  
  private func create(_ newName: String) {
    var newName = newName.trimmingCharacters(in: .whitespacesAndNewlines)
    
    self.name = newName
    
    if newName.isEmpty {
      return
    }
    
    self.name = ""
    
    self.trelloApi.createCard(list: self.list, name: newName, description: "") { card in
      print("card \(card.name) created")
    }
  }
  
  func debounce(interval: TimeInterval, queue: DispatchQueue = DispatchQueue.main, action: @escaping (() -> Void)) -> () -> Void {
    var lastFireTime = DispatchTime.now()
    let dispatchDelay = DispatchTimeInterval.milliseconds(Int(interval * 1000))
    
    return {
      let dispatchTime: DispatchTime = lastFireTime + dispatchDelay
      queue.asyncAfter(deadline: dispatchTime) {
        let now = DispatchTime.now()
        let when = now + dispatchDelay
        if when >= now {
          action()
        }
      }
      lastFireTime = DispatchTime.now()
    }
  }

}

struct AddCardView_Previews: PreviewProvider {
  static var previews: some View {
    AddCardView(list: .constant(List(id: "id", name: "list name")), showAddCard: .constant(true))
  }
}
