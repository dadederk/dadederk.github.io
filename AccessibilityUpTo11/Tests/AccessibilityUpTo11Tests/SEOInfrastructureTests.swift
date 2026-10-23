import XCTest
@testable import AccessibilityUpTo11

final class SEOInfrastructureTests: XCTestCase {
    func testCanonicalPageURLsMatchDirectoryHosting() {
        XCTAssertEqual(SiteMeta.canonicalPagePath("/"), "/")
        XCTAssertEqual(SiteMeta.canonicalPagePath("/about"), "/about/")
        XCTAssertEqual(SiteMeta.canonicalPagePath("about"), "/about/")
        XCTAssertEqual(SiteMeta.canonicalPagePath("/feed.rss"), "/feed.rss")
        XCTAssertEqual(
            SiteMeta.absolutePageURL(for: "/post/example"),
            "https://accessibilityupto11.com/post/example/"
        )
    }

    func testMetadataEscapingProtectsAttributeBoundaries() {
        let value = #"Use "Tailor VoiceOver" & test <content>"#
        XCTAssertEqual(
            HTMLMetadataEscaper.attribute(value),
            "Use &quot;Tailor VoiceOver&quot; &amp; test &lt;content&gt;"
        )
        XCTAssertEqual(
            HTMLMetadataEscaper.text("Accessibility & <iOS>"),
            "Accessibility &amp; &lt;iOS&gt;"
        )
    }

    func testCanonicalPublisherRewritesOnlyExistingInternalPages() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let about = root.appendingPathComponent("about", isDirectory: true)
        try FileManager.default.createDirectory(at: about, withIntermediateDirectories: true)
        try "ok".write(
            to: about.appendingPathComponent("index.html"),
            atomically: true,
            encoding: .utf8
        )
        addTeardownBlock {
            try? FileManager.default.removeItem(at: root)
        }

        let html = #"<a href="/about">About</a><a href="/about#bio">Bio</a><a href="/missing">Missing</a><a href="/feed.rss">RSS</a><a href="https://example.com">External</a>"#
        let rewritten = CanonicalURLPublisher.rewrite(html: html, buildDirectory: root)

        XCTAssertTrue(rewritten.contains(#"href="/about/"#))
        XCTAssertTrue(rewritten.contains(#"href="/about/#bio"#))
        XCTAssertTrue(rewritten.contains(#"href="/missing"#))
        XCTAssertTrue(rewritten.contains(#"href="/feed.rss"#))
        XCTAssertTrue(rewritten.contains(#"href="https://example.com"#))
    }

    @MainActor func testTopicIntroductionsCoverPriorityQueries() {
        XCTAssertTrue(Days365TagPage.topicIntroduction(for: "VoiceOver").contains("VoiceOver"))
        XCTAssertTrue(Days365TagPage.topicIntroduction(for: "accessibilityLabel").contains("accessibility labels"))
        XCTAssertTrue(Days365TagPage.topicIntroduction(for: "SwiftUI").contains("SwiftUI"))
    }
}
