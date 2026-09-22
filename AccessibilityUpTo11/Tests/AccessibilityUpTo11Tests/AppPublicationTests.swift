import XCTest
@testable import AccessibilityUpTo11

final class AppPublicationTests: XCTestCase {
    func testUnpublishedAppsAreHiddenByDefault() {
        let apps = AppsJSONLoader.loadAppsContent(environment: [:]).apps

        XCTAssertFalse(apps.contains { $0.slug == "max-the-game" })
        XCTAssertTrue(apps.contains { $0.slug == "retrorapid" })
    }

    func testPreviewFlagIncludesUnpublishedApps() {
        let apps = AppsJSONLoader.loadAppsContent(environment: [
            AppsJSONLoader.includeUnpublishedAppsEnvironmentKey: "1"
        ]).apps

        XCTAssertTrue(apps.contains { $0.slug == "max-the-game" })
    }

    func testXarraUniversalLinksIncludeDocumentEntities() throws {
        let route = try XCTUnwrap(
            UniversalLinkConfiguration.routes.first { $0.slug == "xarra" }
        )

        XCTAssertTrue(route.allPaths.contains("/apps/xarra/document/*"))
    }

    @MainActor func testOnlyXarraPublishesPressPageWithPressMetadata() throws {
        let pressPages = AccessibilityUpTo11Site().staticPages
            .compactMap { $0 as? UniversalAppPage }
            .filter { $0.pageType == .press }

        XCTAssertEqual(pressPages.map(\.path), ["/apps/xarra/press"])

        let xarra = try XCTUnwrap(AppsData.loadContent().apps.first { $0.slug == "xarra" })
        let meta = MetaBuilder.app(xarra, pageType: .press)
        XCTAssertEqual(meta.path, "/apps/xarra/press")
        XCTAssertTrue(meta.title.contains("Press Kit"))
        XCTAssertTrue(meta.description.contains("full-resolution screenshots"))
    }
}
