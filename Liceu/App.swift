//
//  App.swift
//  Liceu
//
//  Created by Thiago Campos on 23/08/26.
//

import SwiftData
import SwiftUI

@main
struct Liceu: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Deck.self, Flashcard.self])
    }
}
