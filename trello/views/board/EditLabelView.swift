//
//  EditLabelView.swift
//  trello
//
//  Created by Jan Christophersen on 12.11.22.
//

import SwiftUI

enum LabelColor: String, CaseIterable {
  case greenLight = "green_light"
  case green = "green"
  case greenDark = "green_dark"
  case yellowLight = "yellow_light"
  case yellow = "yellow"
  case yellowDark = "yellow_dark"
  case orangeLight = "orange_light"
  case orange = "orange"
  case orangeDark = "orange_dark"
  case redLight = "red_light"
  case red = "red"
  case redDark = "red_dark"
  case purpleLight = "purple_light"
  case purple = "purple"
  case purpleDark = "purple_dark"
  case blueLight = "blue_light"
  case blue = "blue"
  case blueDark = "blue_dark"
  case skyLight = "sky_light"
  case sky = "sky"
  case skyDark = "sky_dark"
  case limeLight = "lime_light"
  case lime = "lime"
  case limeDark = "lime_dark"
  case pinkLight = "pink_light"
  case pink = "pink"
  case pinkDark = "pink_dark"
  case blackLight = "black_light"
  case black = "black"
  case blackDark = "black_dark"
}

let colorsGrid: [[LabelColor]] = [
  [.greenLight, .green, .greenDark, .blueLight, .blue, .blueDark],
  [.yellowLight, .yellow, .yellowDark, .skyLight, .sky, .skyDark],
  [.orangeLight, .orange, .orangeDark, .limeLight, .lime, .limeDark],
  [.redLight, .red, .redDark, .pinkLight, .pink, .pinkDark],
  [.purpleLight, .purple, .purpleDark, .blackLight, .black, .blackDark],
]

struct LabelColorView: View {
  let color: LabelColor
  
  var body: some View {
    Rectangle()
      .fill(Color("LabelFg_\(color.rawValue)"))
      .frame(width: 48, height: 32)
      .cornerRadius(4)
  }
}

struct EditLabelView: View {
  @EnvironmentObject var trelloApi: TrelloApi
  @EnvironmentObject var boardVm: BoardState
  
  let label: Label
  let isNew: Bool
  
  @State private var name: String = ""
  @State private var color: LabelColor? = nil
  
  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        if let color = self.color {
          Circle().fill(Color("LabelFg_\(color.rawValue)")).frame(width: 6, height: 6)
        }
        TextField("", text: $name)
          .textFieldStyle(.plain)
          .font(.title2)
          .foregroundColor(self.color != nil ? Color("LabelText") : Color("TwZinc300"))
          .lineLimit(1)
      }
      .padding(.horizontal, 6)
      .padding(.vertical, 4)
      .background(self.color != nil ? Color("LabelBg_\(self.color!.rawValue)") : Color("TwZinc700"))
      .cornerRadius(4)
      
      Text("Color")
        .font(.title2)
      
      VStack(alignment: .leading) {
        Button(action: {
          self.color = nil
        }) {
          Spacer()
        }
        .buttonStyle(FlatButton(icon: "xmark", text: "Remove color"))
        HStack {
          ForEach(colorsGrid, id: \.self) { column in
            VStack {
              ForEach(column, id: \.self.rawValue) { color in
                LabelColorView(color: color)
                  .onTapGesture {
                    self.color = color
                  }
                  .overlay {
                    if self.color == color {
                      Image(systemName: "checkmark")
                        .foregroundColor(Color("LabelFg_\(color.rawValue)"))
                    }
                  }
              }
            }
          }
        }
        .coordinateSpace(name: "colors")
      }
      .padding(.horizontal, 8)
      
      HStack {
        Button(action: {
          // TODO: move to BoardState
          if isNew {
            self.trelloApi.createLabel(boardId: self.boardVm.board.id, name: self.name, color: self.color) { label in
              self.name = ""
              self.color = nil
            }
          } else {
            self.trelloApi.updateLabel(labelId: label.id, name: self.name, color: self.color) { label in
              
            }
          }
        }) {
          
        }
        .padding(.vertical, 8)
        .buttonStyle(FlatButton(text: isNew ? "Create" : "Save", color: Color("TwZinc600")))
        
        if !isNew {
          Button(action: {
            self.trelloApi.deleteLabel(labelId: label.id) { }
          }) {
          }
          .padding(.vertical, 8)
          .buttonStyle(IconButton(icon: "trash", size: 16, color: Color("TwRed900"), hoverColor: Color("TwRed800")))
        }
      }
      
      Spacer()
    }
    .padding()
    .onChange(of: label) { nl in
      name = nl.name
      if let labelColor = nl.color {
        color = LabelColor(rawValue: labelColor)
      } else {
        color = nil
      }
    }
    .onAppear {
      name = label.name
      if let labelColor = label.color {
        color = LabelColor(rawValue: labelColor)
      } else {
        color = nil
      }
    }
  }
}

struct EditLabelView_Previews: PreviewProvider {
  static var previews: some View {
    EditLabelView(label: Label(id: "id", name: "name", color: "red_dark"), isNew: false)
  }
}
