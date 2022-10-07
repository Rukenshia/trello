//
//  ListViewModel.swift
//  trello
//
//  Created by Jan Christophersen on 07.10.22.
//

import Foundation

class ListViewModel: ObservableObject {
    
    @Published var cards: [Card];
    
    init(cards: [Card]) {
        self.cards = cards;
    }
}
