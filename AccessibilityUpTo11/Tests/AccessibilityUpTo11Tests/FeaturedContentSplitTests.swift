import XCTest
@testable import AccessibilityUpTo11

final class FeaturedContentSplitTests: XCTestCase {
    func testQuotedFeaturesStayAheadOfMentionsAndOnlyTwoStayPrimary() {
        let split = FeaturedContentSplit.split(
            mentions: [
                FeaturedMention(title: "Quoted link", target: "https://example.com/a"),
                FeaturedMention(title: "Extra", target: "https://example.com/extra")
            ],
            quotes: [
                FeaturedQuoteItem(text: "First", sourceTitle: "A", sourceTarget: "https://example.com/a"),
                FeaturedQuoteItem(text: "Second", sourceTitle: "B", sourceTarget: "https://example.com/b"),
                FeaturedQuoteItem(text: "Third", sourceTitle: "C", sourceTarget: "https://example.com/c")
            ]
        )

        XCTAssertEqual(split.primary.quotes.map(\.text), ["First", "Second"])
        XCTAssertTrue(split.primary.mentions.isEmpty)
        XCTAssertEqual(split.additional.quotes.map(\.text), ["Third"])
        XCTAssertEqual(split.additional.mentions.map(\.title), ["Extra"])
    }

    func testTwoFeaturesStayTogether() {
        let split = FeaturedContentSplit.split(
            mentions: [
                FeaturedMention(title: "Same as quote", target: "https://example.com/a")
            ],
            quotes: [
                FeaturedQuoteItem(text: "First", sourceTitle: "A", sourceTarget: "https://example.com/a"),
                FeaturedQuoteItem(text: "Second", sourceTitle: "B", sourceTarget: "https://example.com/b")
            ]
        )

        XCTAssertEqual(split.primary.quotes.map(\.text), ["First", "Second"])
        XCTAssertTrue(split.primary.mentions.isEmpty)
        XCTAssertTrue(split.additional.isEmpty)
    }
}
