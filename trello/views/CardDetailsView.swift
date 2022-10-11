//
//  CardDetailsView.swift
//  trello
//
//  Created by Jan Christophersen on 24.09.22.
//

import SwiftUI
import MarkdownUI

struct CardDetailsView: View {
    
    let card: Card;
    
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
                    HStack {
                        ForEach(card.labels) { label in
                            LabelView(label: label)
                        }
                    }
                    Markdown(card.desc)
                }
//                Spacer()
//                VStack(alignment: .leading) {
//                    Text("")
//                }
            }.frame(alignment: .top)
        }
        .padding(16)
    }
}

struct CardDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        CardDetailsView(card: Card(id: UUID().uuidString, name: "A card", desc: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Quis lectus nulla at volutpat diam ut. Nec dui nunc mattis enim ut tellus elementum sagittis. Dictum fusce ut placerat orci nulla. Lobortis elementum nibh tellus molestie nunc non blandit massa. Facilisis sed odio morbi quis commodo odio aenean sed adipiscing. Sapien et ligula ullamcorper malesuada. Nunc sed id semper risus in hendrerit. In vitae turpis massa sed elementum tempus egestas sed. Etiam sit amet nisl purus. Et odio pellentesque diam volutpat commodo sed.\n\nTurpis cursus in hac habitasse platea. Sapien faucibus et molestie ac. Risus nec feugiat in fermentum. Pellentesque elit ullamcorper dignissim cras. Ut eu sem integer vitae justo eget magna. Tincidunt nunc pulvinar sapien et ligula. Vitae tortor condimentum lacinia quis vel eros donec ac odio. Ac placerat vestibulum lectus mauris ultrices eros in cursus. Commodo ullamcorper a lacus vestibulum sed arcu non odio euismod. Non curabitur gravida arcu ac tortor dignissim. Viverra adipiscing at in tellus integer feugiat scelerisque. Blandit volutpat maecenas volutpat blandit aliquam etiam. Faucibus a pellentesque sit amet porttitor eget. Potenti nullam ac tortor vitae purus faucibus ornare suspendisse sed."), isVisible: .constant(true))
    }
}
