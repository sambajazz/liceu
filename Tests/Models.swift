//
//  Models.swift
//  Tests
//
//  Created by Thiago Campos on 23/08/26.
//

import Foundation
import FSRS
@testable import Liceu
import Testing

struct DeckTests {
    @Test("Deck only requires a name")
    func createDeckWithMinimumInput() {
        let deck = Deck(name: "French")
        #expect(deck.name == "French")
    }

    @Test("Deck has an optional summary")
    func deckHasSummary() {
        let summary = "Learning french for my upcoming Paris travel"
        let deck = Deck(name: "French", summary: summary)
        #expect(deck.summary == summary)
    }

    @Test("Deck's dates are registered on init")
    func deckHasCreatedAt() {
        let deck = Deck(name: "French")
        #expect(deck.createdAt.timeIntervalSinceNow < 1)
        #expect(deck.updatedAt.timeIntervalSinceNow < 1)
    }

    @Test("Deck should be able to be archived")
    func deckCanBeArchived() {
        let deck = Deck(name: "French")
        deck.isArchived = true
        #expect(deck.isArchived == true)
    }

    @Test("Deck comes with default settings and parameters")
    func deckComesWithDefaultSettings() {
        let deck = Deck(name: "French")
        #expect(deck.newCardsPerDay == 20)
        #expect(deck.reviewsPerDay == 200)
        #expect(deck.fsrsParameters.requestRetention == 0.9)
        #expect(deck.fsrsParameters.maximumInterval == 36500)
        #expect(deck.fsrsParameters.enableFuzz == false)
        #expect(deck.fsrsParameters.enableShortTerm == true)
    }
}
