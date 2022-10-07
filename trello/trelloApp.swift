//
//  trelloApp.swift
//  trello
//
//  Created by Jan Christophersen on 24.09.22.
//

import SwiftUI

@main
struct trelloApp: App {
    @EnvironmentObject var trello: TrelloApi
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(TrelloApi(key: "***REMOVED***", token: "***REMOVED***"))
        }
    }
}
