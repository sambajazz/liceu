//
//  Deck.swift
//  Liceu
//
//  Created by Thiago Campos on 23/08/26.
//

import Foundation
import FSRS
import SwiftData

@Model
final class Deck {
    var name: String
    var summary: String?
    var isArchived: Bool
    // Metadata
    var createdAt: Date
    var updatedAt: Date
    // Settings
    var newCardsPerDay: Int
    var reviewsPerDay: Int
    var fsrsParameters: FSRSParameters

    @Relationship(deleteRule: .cascade, inverse: \Flashcard.deck)
    var flashcards: [Flashcard] = []

    init(name: String, summary: String? = nil, isArchived: Bool = false) {
        self.name = name
        self.summary = summary
        self.isArchived = isArchived
        createdAt = .now
        updatedAt = .now
        // Based off FSRS's FSRSDefault
        newCardsPerDay = 20
        reviewsPerDay = 200
        fsrsParameters = .init(
            requestRetention: 0.9,
            maximumInterval: 36500,
            enableFuzz: false,
            enableShortTerm: true
        )
    }
}
