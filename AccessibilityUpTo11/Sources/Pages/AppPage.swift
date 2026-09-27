import Foundation
import Ignite

// Universal AppPage that handles all app-related pages based on page type
struct UniversalAppPage: StaticPage {
    let appIdentifier: String
    let pageType: AppPageType
    
    enum AppPageType {
        case main
        case terms
        case privacy
        case open
        case press
        
        var pathSegment: String {
            switch self {
            case .main: return ""
            case .terms: return "/terms"
            case .privacy: return "/privacy"
            case .open: return "/open"
            case .press: return "/press"
            }
        }
        
        var titleSuffix: String {
            switch self {
            case .main: return ""
            case .terms: return " - Terms & Conditions"
            case .privacy: return " - Privacy Policy"
            case .open: return " - Open in App"
            case .press: return " - Press Kit"
            }
        }
        
        var fileName: String {
            switch self {
            case .main: return ""
            case .terms: return "terms.md"
            case .privacy: return "privacy.md"
            case .open: return ""
            case .press: return ""
            }
        }
        
        var notFoundMessage: String {
            switch self {
            case .main: return "App not found"
            case .terms: return "Terms & Conditions not found for this app."
            case .privacy: return "Privacy Policy not found for this app."
            case .open: return "App not found."
            case .press: return "Press kit not found for this app."
            }
        }
    }
    
    init(appIdentifier: String, pageType: AppPageType = .main) {
        self.appIdentifier = appIdentifier
        self.pageType = pageType
    }
    
    var title: String {
        guard let app = findApp() else { return pageType.notFoundMessage }
        return "\(app.title)\(pageType.titleSuffix)"
    }
    
    var path: String { "/apps/\(appIdentifier)\(pageType.pathSegment)" }

    var description: String {
        guard let app = findApp() else { return SiteMeta.defaultDescription }

        switch pageType {
        case .main:
            return app.description
        case .terms:
            return "Terms and conditions for \(app.title), including usage and support information."
        case .privacy:
            return "Privacy policy for \(app.title), including data collection, usage, and protection details."
        case .open:
            return "Open \(app.title) in the app when installed, with automatic App Store fallback."
        case .press:
            return "Facts, copy, full-resolution screenshots, app icons, and contact details for coverage of \(app.title)"
        }
    }

    var image: URL? {
        guard let app = findApp() else { return SiteMeta.imageURL(nil) }
        return SiteMeta.imageURL(app.imagePath)
    }
    
    @MainActor var body: some HTML {
        switch pageType {
        case .main:
            renderMainPage()
        case .terms, .privacy:
            renderLegalPage()
        case .open:
            renderOpenRedirectPage()
        case .press:
            if let app = findApp(), app.slug == "xarra" {
                XarraPressContent(app: app)
            } else {
                Text(pageType.notFoundMessage)
            }
        }
    }
    
    // MARK: - Main App Page
    @MainActor private func renderMainPage() -> some HTML {
        // 32pt between major blocks, 16pt under a section heading, 8pt between a
        // subsection title and the content it labels. The title line box keeps
        // about 8pt of descender under the letters; the capsules use that inset
        // so their bottoms meet the type.
        let blockSpacing = 32
        let headingSpacing = 16
        let subsectionSpacing = 8
        let titleDescender = 8

        return VStack(alignment: .leading, spacing: blockSpacing) {
            if let app = findApp() {
                HStack(alignment: .center, spacing: headingSpacing) {
                    Image(app.imagePath, description: app.imageDescription)
                        .resizable()
                        .aspectRatio(.square, contentMode: .fit)
                        .frame(width: 132, height: 132)
                        .style(.flex, "0 0 auto")

                    VStack(alignment: .leading, spacing: subsectionSpacing) {
                        HStack(alignment: .bottom, spacing: 10) {
                            BrandCopy.titleText(app.title)
                                .font(.title1)
                                .fontWeight(.bold)
                                .lineSpacing(1)
                                .horizontalAlignment(.leading)

                            if !app.platforms.isEmpty {
                                PlatformPillRow(platforms: app.platforms, appearance: .badge)
                                    .padding(.bottom, titleDescender)
                            }
                        }
                        .style(.flexWrap, "wrap")

                        Text(app.subtitle)
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    }
                    .style(.flex, "1 1 auto")
                    .style(.minWidth, "0")
                }
                .style(.flexWrap, "wrap")
                .style(.width, "100%")

                VStack(alignment: .leading, spacing: headingSpacing) {
                    Text(app.description)
                        .font(.body)

                    if !app.nameOrigin.isEmpty {
                        Text(app.nameOrigin)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                }

                HStack(alignment: .center, spacing: 12) {
                    ForEach(app.actions.filter { isAppStoreLink($0.target) }) { action in
                        AppStoreDownloadBadge(target: action.target)
                    }

                    if app.slug == "xarra" {
                        ActionButton(
                            title: "Press Kit",
                            target: "/apps/xarra/press/",
                            style: .primary
                        )
                    }

                    ForEach(app.actions.filter { !isAppStoreLink($0.target) }) { action in
                        ActionButton(
                            title: action.title,
                            target: action.target,
                            style: action.style == "primary" ? .primary : .secondary
                        )
                    }

                    PillLink(title: "Terms & Conditions", target: "/apps/\(appIdentifier)/terms")
                    PillLink(title: "Privacy Policy", target: "/apps/\(appIdentifier)/privacy")
                    PillLink(title: "Support & Contact", target: "#support-contact")
                }
                .class("action-row")
                .style(.flexWrap, "wrap")

                if !app.featuredIn.isEmpty {
                    FeaturedInBox(
                        title: "Featured in",
                        mentions: app.featuredIn,
                        quote: app.featuredQuote,
                        quoteSourceTitle: app.featuredQuoteSourceTitle,
                        quoteSourceTarget: app.featuredQuoteSourceTarget
                    )
                    .style(.width, "100%")
                }

                if !app.featureGroups.isEmpty {
                    VStack(alignment: .leading, spacing: headingSpacing) {
                        Text("Features")
                            .font(.title2)
                            .fontWeight(.bold)
                            .horizontalAlignment(.leading)

                        VStack(alignment: .leading, spacing: blockSpacing) {
                            ForEach(app.featureGroups) { group in
                                VStack(alignment: .leading, spacing: subsectionSpacing) {
                                    Text(group.title)
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .horizontalAlignment(.leading)

                                    Grid(alignment: .topLeading) {
                                        ForEach(group.features) { feature in
                                            AppFeatureCard(
                                                feature: feature,
                                                fallbackImagePath: app.imagePath,
                                                fallbackImageDescription: app.imageDescription
                                            )
                                            .width(4)
                                        }
                                    }
                                }
                            }
                        }
                    }
                } else {
                    VStack(alignment: .leading, spacing: headingSpacing) {
                        Text("Features")
                            .font(.title2)
                            .fontWeight(.bold)
                            .horizontalAlignment(.leading)

                        Grid(alignment: .topLeading) {
                            ForEach(app.features) { feature in
                                AppFeatureCard(
                                    feature: feature,
                                    fallbackImagePath: app.imagePath,
                                    fallbackImageDescription: app.imageDescription
                                )
                                .width(4)
                            }
                        }
                    }
                }

                if app.whySection != nil || !app.customerQuotes.isEmpty {
                    VStack(alignment: .leading, spacing: blockSpacing) {
                        VStack(alignment: .leading, spacing: headingSpacing) {
                            BrandCopy.whySectionTitle(for: app.title)
                                .font(.title2)
                                .fontWeight(.bold)
                                .horizontalAlignment(.leading)

                            if let whySection = app.whySection {
                                Text(whySection)
                                    .font(.body)
                            }
                        }

                        if !app.customerQuotes.isEmpty {
                            FeaturedInBox(
                                title: "What people are saying",
                                mentions: [],
                                quotes: app.customerQuotes,
                                trailingImage: ratingCard(for: app.slug)
                            )
                            .style(.width, "100%")
                        }
                    }
                }

                VStack(alignment: .leading, spacing: headingSpacing) {
                    Text("Support & Contact")
                        .font(.title2)
                        .fontWeight(.bold)
                        .horizontalAlignment(.leading)

                    Text(app.supportText)
                        .font(.body)
                        .horizontalAlignment(.leading)

                    HStack {
                        ActionButton(title: "Contact", target: "mailto:\(app.contactEmail)", style: .primary)
                            .horizontalAlignment(.leading)
                    }
                }
                .id("support-contact")
            } else {
                Text(pageType.notFoundMessage)
                    .font(.title2)
                    .foregroundStyle(.secondary)
                    .padding(.vertical)
            }
        }
        .padding(.top, 24)
    }
    
    // MARK: - Legal Pages
    @MainActor private func renderLegalPage() -> some HTML {
        VStack(alignment: .leading) {
            if let app = findApp() {
                // Header with app info and back link
                Section {
                    HStack(alignment: .center) {
                        Image(decorative: app.imagePath)
                            .resizable()
                            .aspectRatio(.square, contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .padding(.trailing)

                        VStack(alignment: .leading) {
                            // A span keeps the title size without emitting an h2
                            // ahead of the document h1 in the legal markdown.
                            Span {
                                BrandCopy.inlineTitle(app.title)
                                Span(pageType.titleSuffix)
                            }
                            .font(.title2)
                            .fontWeight(.bold)
                            .horizontalAlignment(.leading)

                            Link(target: "/apps/\(appIdentifier)") {
                                Span("← Back to ")
                                BrandCopy.inlineTitle(app.title)
                            }
                            .style(.textDecoration, "none")
                            .foregroundStyle(.secondary)
                            .horizontalAlignment(.leading)
                        }
                    }
                }
                .frame(width: .percent(100%))
                .padding(.bottom, 10)
                
                // Legal content
                Section {
                    if let content = loadLegalContent() {
                        MarkdownRenderer(content: content)
                    } else {
                        Text(pageType.notFoundMessage)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical)
            } else {
                // App not found
                Section {
                    Text(pageType.notFoundMessage)
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical)
            }
        }
    }
    
    // MARK: - Open Redirect Page
    @MainActor private func renderOpenRedirectPage() -> some HTML {
        VStack(alignment: .leading) {
            if let app = findApp(), let appStoreTarget = appStoreURLTarget(for: app) {
                Section {
                    Text {
                        Span("Opening ")
                        BrandCopy.inlineTitle(app.title)
                        Span("…")
                    }
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.bottom, 6)

                    Text("If the app does not open automatically, continue to the App Store.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 12)

                    Link("Download on the App Store", target: appStoreTarget)
                        .linkStyle(.button)
                        .role(.primary)
                        .padding(.bottom, 12)

                    Link(target: "/apps/\(appIdentifier)") {
                        Span("View ")
                        BrandCopy.inlineTitle(app.title)
                        Span(" details on this site")
                    }
                        .style(.textDecoration, "none")
                        .foregroundStyle(.secondary)

                    Script(code: """
                    window.location.replace('\(escapeForJavaScript(appStoreTarget))');
                    """)
                }
                .padding(.vertical)
            } else if findApp() != nil {
                Section {
                    Text("App Store link unavailable")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 6)

                    Link("Back to app page", target: "/apps/\(appIdentifier)")
                }
                .padding(.vertical)
            } else {
                Section {
                    Text(pageType.notFoundMessage)
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical)
            }
        }
    }

    // MARK: - Helper Methods
    private func findApp() -> AppItem? {
        let appsData = AppsData.loadContent()
        let normalizedIdentifier = appIdentifier.lowercased()
        return appsData.apps.first { app in
            app.slug.lowercased() == normalizedIdentifier
        }
    }

    private func ratingCard(for slug: String) -> FeaturedBannerImage? {
        switch slug.lowercased() {
        case "xarra":
            return FeaturedBannerImage(
                path: "/Images/Site/Apps/Xarra/GlobalAppStoreRating-2026-09.png",
                description: "Xarra worldwide App Store rating: 5.0 out of 5 from 7 ratings, September 2026."
            )
        case "retrorapid":
            return FeaturedBannerImage(
                path: "/Images/Site/Apps/RetroRapid/GlobalAppStoreRating-2026-09.png",
                description: "RetroRapid worldwide App Store rating: 4.8 out of 5 from 58 ratings, September 2026."
            )
        case "imonstickers":
            return FeaturedBannerImage(
                path: "/Images/Site/Apps/iMonstickers/GlobalAppStoreRating-2026-09.png",
                description: "iMonstickers worldwide App Store rating: 5.0 out of 5 from 2 ratings, September 2026."
            )
        default:
            return nil
        }
    }
    
    private func loadLegalContent() -> String? {
        guard let app = findApp() else { return nil }
        let folderName = app.legalContentDirectory
            ?? app.title.replacingOccurrences(of: "!", with: "")
        let contentPath = "AppsData/\(folderName)/\(pageType.fileName)"
        
        let url = URL(fileURLWithPath: contentPath)
        guard FileManager.default.fileExists(atPath: url.path) else {
            return nil
        }
        
        do {
            return try String(contentsOf: url)
        } catch {
            print("Error loading \(pageType.fileName) content: \(error)")
            return nil
        }
    }

    private func isAppStoreLink(_ target: String) -> Bool {
        target.contains("apps.apple.com")
    }

    private func appStoreURLTarget(for app: AppItem) -> String? {
        if let appStoreAction = app.actions.first(where: { $0.target.contains("apps.apple.com") }) {
            return appStoreAction.target
        }

        return app.actions.first?.target
    }

    private func escapeForJavaScript(_ value: String) -> String {
        value
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "'", with: "\\'")
    }
    
}
