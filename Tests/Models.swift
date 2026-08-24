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

struct FlashcardTests {
    @Test("Flashcard only requires front and back values")
    func flashcardWithMinimumInput() {
        let flashcard = Flashcard(front: "Bonjour", back: "Bom dia")
        #expect(flashcard.front == "Bonjour")
        #expect(flashcard.back == "Bom dia")
    }

    @Test("Flashcard's dates are registered on init")
    func flashcardHasCreatedAt() {
        let flashcard = Flashcard(front: "Bonjour", back: "Bom dia")
        #expect(flashcard.createdAt.timeIntervalSinceNow < 1)
        #expect(flashcard.updatedAt.timeIntervalSinceNow < 1)
    }

    @Test("Flashcard should be able to be archived")
    func flashcardCanBeArchived() {
        let flashcard = Flashcard(front: "Bonjour", back: "Bom dia")
        flashcard.isArchived = true
        #expect(flashcard.isArchived == true)
    }

    @Test("Flashcard comes with default settings and parameters")
    func flashcardComesWithDefaultSettings() {
        let flashcard = Flashcard(front: "Bonjour", back: "Bom dia")
        let card = Card()
        #expect(abs(flashcard.due.timeIntervalSince(card.due)) < 1)
        #expect(flashcard.stability == card.stability)
        #expect(flashcard.difficulty == card.difficulty)
        #expect(flashcard.elapsedDays == card.elapsedDays)
        #expect(flashcard.scheduledDays == card.scheduledDays)
        #expect(flashcard.reps == card.reps)
        #expect(flashcard.lapses == card.lapses)
        #expect(flashcard.stateRaw == card.state.rawValue)
        #expect(flashcard.lastReview == card.lastReview)
    }

    @Test("Flashcard's state is derived from its raw value")
    func flashcardDerivesState() {
        let flashcard = Flashcard(front: "Bonjour", back: "Bom dia")
        #expect(flashcard.state == .new)
        flashcard.stateRaw = CardState.review.rawValue
        #expect(flashcard.state == .review)
    }

    @Test("Flashcard falls back to the new state for an unknown raw value")
    func flashcardFallsBackToNewState() {
        let flashcard = Flashcard(front: "Bonjour", back: "Bom dia")
        flashcard.stateRaw = 99
        #expect(flashcard.state == .new)
    }

    /// Parameterized arguments must be `Sendable` and `CardState` is not, so the
    /// states are passed as the raw values the flashcard stores.
    @Test(
        "Flashcard is only learning while it is being learned or relearned",
        arguments: [
            (CardState.new.rawValue, false),
            (CardState.learning.rawValue, true),
            (CardState.review.rawValue, false),
            (CardState.relearning.rawValue, true),
        ]
    )
    func flashcardIsLearning(stateRaw: Int, expected: Bool) {
        let flashcard = Flashcard(front: "Bonjour", back: "Bom dia")
        flashcard.stateRaw = stateRaw
        #expect(flashcard.isLearning == expected)
    }

    @Test("Flashcard exposes its FSRS fields as a card")
    func flashcardExposesFSRSCard() {
        let flashcard = Flashcard(front: "Bonjour", back: "Bom dia")
        // Every parameter of `Card.init` has a default, so a field the bridge
        // drops would still match if these were left at their initial values.
        flashcard.due = .now.addingTimeInterval(86400)
        flashcard.stability = 4.2
        flashcard.difficulty = 6.7
        flashcard.elapsedDays = 1
        flashcard.scheduledDays = 3
        flashcard.reps = 2
        flashcard.lapses = 1
        flashcard.stateRaw = CardState.review.rawValue
        flashcard.lastReview = .now
        let card = flashcard.fsrsCard
        #expect(card.due == flashcard.due)
        #expect(card.stability == flashcard.stability)
        #expect(card.difficulty == flashcard.difficulty)
        #expect(card.elapsedDays == flashcard.elapsedDays)
        #expect(card.scheduledDays == flashcard.scheduledDays)
        #expect(card.reps == flashcard.reps)
        #expect(card.lapses == flashcard.lapses)
        #expect(card.state.rawValue == flashcard.stateRaw)
        #expect(card.lastReview == flashcard.lastReview)
    }

    @Test("Flashcard applies the result of a scheduling operation")
    func flashcardAppliesCard() {
        let flashcard = Flashcard(front: "Bonjour", back: "Bom dia")
        let card = Card(
            due: .now.addingTimeInterval(86400),
            stability: 4.2,
            difficulty: 6.7,
            elapsedDays: 1,
            scheduledDays: 3,
            reps: 2,
            lapses: 1,
            state: .review,
            lastReview: .now
        )
        flashcard.apply(card)
        #expect(flashcard.due == card.due)
        #expect(flashcard.stability == card.stability)
        #expect(flashcard.difficulty == card.difficulty)
        #expect(flashcard.elapsedDays == card.elapsedDays)
        #expect(flashcard.scheduledDays == card.scheduledDays)
        #expect(flashcard.reps == card.reps)
        #expect(flashcard.lapses == card.lapses)
        #expect(flashcard.stateRaw == card.state.rawValue)
        #expect(flashcard.lastReview == card.lastReview)
    }

    @Test("Flashcard round-trips through FSRS's card")
    func flashcardRoundTripsThroughCard() {
        let flashcard = Flashcard(front: "Bonjour", back: "Bom dia")
        let card = Card(
            due: .now.addingTimeInterval(86400),
            stability: 4.2,
            difficulty: 6.7,
            elapsedDays: 1,
            scheduledDays: 3,
            reps: 2,
            lapses: 1,
            state: .review,
            lastReview: .now
        )
        flashcard.apply(card)
        // Comparing whole cards fails if `Card` gains a property that only one
        // side of the bridge is taught about.
        #expect(flashcard.fsrsCard == card)
    }

    @Test("Flashcard starts out having never been introduced")
    func flashcardStartsNotIntroduced() {
        let flashcard = Flashcard(front: "Bonjour", back: "Bom dia")
        #expect(flashcard.introducedAt == nil)
    }

    @Test("Leaving the new queue introduces the flashcard")
    func flashcardIsIntroducedOnLeavingTheNewQueue() {
        let flashcard = Flashcard(front: "Bonjour", back: "Bom dia")
        let review = Date.now
        flashcard.apply(Card(state: .learning, lastReview: review))
        #expect(flashcard.introducedAt == review)
    }

    @Test("Reviewing an introduced flashcard keeps its introduction date")
    func flashcardKeepsIntroducedAtAcrossReviews() {
        let flashcard = Flashcard(front: "Bonjour", back: "Bom dia")
        let introduction = Date.now.addingTimeInterval(-86400)
        flashcard.apply(Card(state: .learning, lastReview: introduction))
        flashcard.apply(Card(state: .review, lastReview: .now))
        #expect(flashcard.introducedAt == introduction)
    }

    @Test("Returning a flashcard to the new queue takes back its introduction")
    func flashcardLosesIntroducedAtWhenReturnedToNew() {
        let flashcard = Flashcard(front: "Bonjour", back: "Bom dia")
        flashcard.apply(Card(state: .review, lastReview: .now))
        // `FSRS.forget` returns a new card that keeps its `lastReview`.
        flashcard.apply(Card(state: .new, lastReview: .now))
        #expect(flashcard.introducedAt == nil)
    }

    @Test("Reviewing a flashcard that predates introduction dates does not introduce it")
    func flashcardWithoutIntroducedAtIsNotBackfilled() {
        let flashcard = Flashcard(front: "Bonjour", back: "Bom dia")
        // Stands in for a card stored before `introducedAt` existed: already past
        // the new queue, but with no introduction date recorded.
        flashcard.stateRaw = CardState.review.rawValue
        flashcard.introducedAt = nil
        flashcard.apply(Card(state: .review, lastReview: .now))
        #expect(flashcard.introducedAt == nil)
    }

    @Test("Applying a card marks the flashcard as updated")
    func flashcardApplyBumpsUpdatedAt() {
        let flashcard = Flashcard(front: "Bonjour", back: "Bom dia")
        let createdAt = flashcard.createdAt
        flashcard.updatedAt = .distantPast
        flashcard.apply(Card())
        #expect(flashcard.updatedAt > flashcard.createdAt)
        #expect(flashcard.createdAt == createdAt)
    }
}
