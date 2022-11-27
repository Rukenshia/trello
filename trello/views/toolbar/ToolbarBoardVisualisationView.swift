//
//  ToolbarBoardVisualisationView.swift
//  trello
//
//  Created by Jan Christophersen on 26.11.22.
//

import SwiftUI

struct BoardVisualisationView: View {
  let type: BoardViewType
  
  var body: some View {
    HStack {
      switch type {
      case .lists:
        Image(systemName: "pause.fill")
        Text("Lists")
      case .table:
        Image(systemName: "tablecells")
        Text("Table")
      }
    }
  }
}

struct ToolbarBoardVisualisationView: View {
  @Binding var viewType: BoardViewType
  
  var body: some View {
    Menu {
      Button(action: {
        viewType = .lists
      }) {
        BoardVisualisationView(type: .lists)
      }
      .buttonStyle(.plain)
      
      Button(action: {
        viewType = .table
      }) {
        BoardVisualisationView(type: .table)
      }
      .buttonStyle(.plain)
    } label: {
      BoardVisualisationView(type: viewType)
    }
  }
}

struct ToolbarBoardVisualisationView_Previews: PreviewProvider {
  static var previews: some View {
    ToolbarBoardVisualisationView(viewType: .constant(.lists))
  }
}
