//
//  ManageBoardLabelsView.swift
//  trello
//
//  Created by Jan Christophersen on 12.11.22.
//

import SwiftUI

struct ManageBoardLabelsView: View {
  let labels: [Label]
  @State private var selection: Label?
  
  var body: some View {
    VStack {
      NavigationSplitView() {
        VStack {
          SwiftUI.List(labels, selection: $selection) { label in
            NavigationLink(value: label) {
              HStack {
                Circle().fill(label.fgColor).frame(width: 6, height: 6)
                Text(label.name)
                  .font(.system(size: 14))
                  .foregroundColor(Color("LabelText"))
                  .lineLimit(1)
                Spacer()
              }
              .padding(.horizontal, 6)
              .padding(.vertical, 4)
              .background(label.bgColor)
              .cornerRadius(4)
            }
          }
          
          Button(action: {
            selection = Label(id: "", name: "", color: LabelColor.green.rawValue)
          }) {
          }
          .buttonStyle(FlatButton(icon: "plus", text: "Create label"))
          .padding()
        }
        .frame(width: 200)
      } detail: {
        if let label = selection {
          EditLabelView(label: label, isNew: label.id.isEmpty)
        } else {
          Text("Select a label to edit")
        }
      }
    }
    .frame(minWidth: 500, minHeight: 600)
    .padding()
  }
}

struct ManageBoardLabelsView_Previews: PreviewProvider {
  static var previews: some View {
    ManageBoardLabelsView(labels: [Label(id: "id", name: "name", color: "blue_light")])
  }
}
