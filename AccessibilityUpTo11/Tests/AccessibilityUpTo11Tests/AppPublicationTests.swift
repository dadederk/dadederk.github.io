import XCTest
@testable import AccessibilityUpTo11

final class AppPublicationTests: XCTestCase {
    func testSelectedAppsIncludeCustomerQuotes() {
        let apps = AppsJSONLoader.loadAppsContent(environment: [:]).apps
        let expectedCounts = ["xarra": 2, "retrorapid": 3, "imonstickers": 2]

        for (slug, count) in expectedCounts {
            let app = apps.first { $0.slug == slug }
            XCTAssertEqual(app?.customerQuotes.count, count, slug)
        }

        XCTAssertTrue(apps.first { $0.slug == "mestre" }?.customerQuotes.isEmpty == true)
    }

    func testAppsNavigationStaysCurrentOnChildPages() {
        let subpage = #"<body data-current-page="/apps/xarra/terms"><a href="/apps" class="nav-link text-nowrap">Apps</a>"#
        let marked = NavigationSectionMarker.markingCurrentSections(in: subpage)

        XCTAssertTrue(marked.contains(#"class="nav-link active text-nowrap" aria-current="page">Apps</a>"#))

        let home = #"<body data-current-page="/"><a href="/apps" class="nav-link text-nowrap">Apps</a>"#
        XCTAssertEqual(NavigationSectionMarker.markingCurrentSections(in: home), home)

        let appsIndex = #"<body data-current-page="/apps"><a href="/apps" class="nav-link active text-nowrap" aria-current="page">Apps</a>"#
        XCTAssertEqual(NavigationSectionMarker.markingCurrentSections(in: appsIndex), appsIndex)
    }

    func testPublishedAppsAreVisibleByDefault() {
        let apps = AppsJSONLoader.loadAppsContent(environment: [:]).apps

        XCTAssertTrue(apps.contains { $0.slug == "max-the-game" })
        XCTAssertTrue(apps.contains { $0.slug == "retrorapid" })
    }

    func testPreviewFlagKeepsPublishedAppsVisible() {
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
