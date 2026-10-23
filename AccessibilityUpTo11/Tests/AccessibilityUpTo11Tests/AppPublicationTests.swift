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

    func testXarraProductCopyIncludesCurrentDiscoveryAndDeviceFeatures() throws {
        let xarra = try XCTUnwrap(
            AppsJSONLoader.loadAppsContent(environment: [:]).apps.first { $0.slug == "xarra" }
        )
        let featureCopy = xarra.featureGroups
            .flatMap(\.features)
            .map { "\($0.title) \($0.description)" }
            .joined(separator: " ")

        for expectedTerm in ["iPhone Duo", "Siri", "Spotlight", "Shortcuts", "EPUB", "Markdown"] {
            XCTAssertTrue(featureCopy.contains(expectedTerm), expectedTerm)
        }
    }

    func testXarraPublishesFreeCommunityAccessOffer() throws {
        let xarra = try XCTUnwrap(
            AppsJSONLoader.loadAppsContent(environment: [:]).apps.first { $0.slug == "xarra" }
        )
        let offer = try XCTUnwrap(xarra.communityOffer)

        XCTAssertEqual(offer.title, "Free access for public organisations and nonprofits")
        XCTAssertTrue(offer.description.contains("free lifetime access"))
        XCTAssertEqual(offer.actionTitle, "Ask about free access")
        XCTAssertTrue(offer.actionTarget.hasPrefix("mailto:hello@accessibilityUpTo11.com"))
    }

    @MainActor func testConfiguredAppsPublishPressPagesWithPressMetadata() throws {
        let pressPages = AccessibilityUpTo11Site().staticPages
            .compactMap { $0 as? UniversalAppPage }
            .filter { $0.pageType == .press }

        XCTAssertEqual(
            Set(pressPages.map(\.path)),
            Set(["/apps/xarra/press", "/apps/retrorapid/press"])
        )

        let xarra = try XCTUnwrap(AppsData.loadContent().apps.first { $0.slug == "xarra" })
        let xarraMeta = MetaBuilder.app(xarra, pageType: .press)
        XCTAssertEqual(xarraMeta.path, "/apps/xarra/press")
        XCTAssertTrue(xarraMeta.title.contains("Press Kit"))
        XCTAssertTrue(xarraMeta.description.contains("full-resolution screenshots"))

        let retroRapid = try XCTUnwrap(AppsData.loadContent().apps.first { $0.slug == "retrorapid" })
        let retroRapidMeta = MetaBuilder.app(retroRapid, pageType: .press)
        XCTAssertEqual(retroRapidMeta.path, "/apps/retrorapid/press")
        XCTAssertTrue(retroRapidMeta.title.contains("Press Kit"))

        let retroRapidKit = try XCTUnwrap(AppPressKits.kit(for: "retrorapid"))
        XCTAssertNil(retroRapidKit.demoVideo)
        XCTAssertNil(retroRapidKit.developer?.photo)
        XCTAssertEqual(retroRapidKit.screenshots?.items.count, 9)
        XCTAssertEqual(retroRapidKit.recognitionTitle, "Coverage")
        XCTAssertEqual(retroRapidKit.additionalMediaSections.count, 1)
        XCTAssertEqual(retroRapidKit.additionalMediaSections.first?.items.count, 2)
        XCTAssertTrue(retroRapidKit.facts.contains { $0.label == "Giving back" })
        XCTAssertFalse(retroRapidKit.facts.contains { $0.label == "Free play" })

        let award = try XCTUnwrap(
            xarra.featuredIn.first {
                $0.target == "https://gaad.foundation/what-we-do/gaadys/winners/xarra"
            }
        )
        XCTAssertEqual(award.title, "One of five 2026 Gaady Award winners — GAAD Foundation")
        XCTAssertEqual(
            XarraRecognition.artworkPath,
            "/Images/Site/Apps/Xarra/Press/xarra-gaady-award-2026.png"
        )
    }
}
