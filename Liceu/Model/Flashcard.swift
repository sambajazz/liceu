//
//  Flashcard.swift
//  Liceu
//
//  Created by Thiago Campos on 23/08/26.
//

import Foundation
import FSRS
import SwiftData

@Model
final class Flashcard {
    var front: String
    var back: String?
    var deck: Deck?
    var isArchived: Bool
    // Metadata
    var createdAt: Date
    var updatedAt: Date
    /// When the card first left the new queue, so that the deck's daily new-card
    /// limit can be counted without persisting the review history. `nil` means
    /// either never introduced or stored before this property existed, so use
    /// `state` to decide what belongs in the new queue.
    var introducedAt: Date?
    // FSRS-related fields
    var due: Date
    var stability: Double
    var difficulty: Double
    var elapsedDays: Double
    var scheduledDays: Double
    var reps: Int
    var lapses: Int
    var stateRaw: Int
    var lastReview: Date?

    init(front: String, back: String? = nil, deck: Deck? = nil) {
        // FSRS's card
        let card = Card()
        self.front = front
        self.back = back
        self.deck = deck
        isArchived = false
        createdAt = .now
        updatedAt = .now
        introducedAt = nil
        due = card.due
        stability = card.stability
        difficulty = card.difficulty
        elapsedDays = card.elapsedDays
        scheduledDays = card.scheduledDays
        reps = card.reps
        lapses = card.lapses
        stateRaw = card.state.rawValue
        lastReview = card.lastReview
    }

    @Transient
    var state: CardState {
        CardState(rawValue: stateRaw) ?? .new
    }

    @Transient
    var isLearning: Bool {
        state == .learning || state == .relearning
    }

    @Transient
    var fsrsCard: Card {
        Card(
            due: due,
            stability: stability,
            difficulty: difficulty,
            elapsedDays: elapsedDays,
            scheduledDays: scheduledDays,
            reps: reps,
            lapses: lapses,
            state: state,
            lastReview: lastReview
        )
    }

    /// Applies the result of an FSRS scheduling operation.
    func apply(_ card: Card) {
        let wasNew = state == .new

        due = card.due
        stability = card.stability
        difficulty = card.difficulty
        elapsedDays = card.elapsedDays
        scheduledDays = card.scheduledDays
        reps = card.reps
        lapses = card.lapses
        stateRaw = card.state.rawValue
        lastReview = card.lastReview
        updatedAt = .now

        // Returning to the new queue gives back the card's daily new-card
        // allowance. Only the new -> not-new transition stamps `introducedAt`,
        // which leaves cards stored before this property existed untouched
        // rather than charging them to today's allowance.
        if card.state == .new {
            introducedAt = nil
        } else if wasNew {
            introducedAt = card.lastReview ?? .now
        }
    }
}
