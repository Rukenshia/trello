//
//  SearchView.swift
//  trello
//
//  Created by Jan Christophersen on 14.11.22.
//

import SwiftUI

struct SearchView: View {
  @State private var search: String = ""
  
  @State private var showResults: Bool = false
  
  var body: some View {
    ZStack {
      TextField("", text: $search)
        .textFieldStyle(.roundedBorder)
      
      if search.isEmpty {
        HStack {
          Text("Type to search...")
            .font(.subheadline)
            .foregroundColor(Color("TwZinc600"))
          Spacer()
        }.padding(.horizontal, 8)
          .allowsHitTesting(false)
      }
      
      HStack {
        Spacer()
        Image(systemName: "magnifyingglass")
          .padding(.trailing, 4)
          .foregroundColor(Color("TwZinc600"))
      }
    }
    .frame(minWidth: 200)
    .popover(isPresented: $showResults, arrowEdge: .bottom) {
      VStack {
        Text("TODO: results")
      }
      .padding()
    }
  }
}

struct SearchView_Previews: PreviewProvider {
  static var previews: some View {
    SearchView()
  }
}
