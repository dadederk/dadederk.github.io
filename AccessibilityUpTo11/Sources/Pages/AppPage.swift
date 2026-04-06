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
        
        var pathSegment: String {
            switch self {
            case .main: return ""
            case .terms: return "/terms"
            case .privacy: return "/privacy"
            case .open: return "/open"
            }
        }
        
        var titleSuffix: String {
            switch self {
            case .main: return ""
            case .terms: return " - Terms & Conditions"
            case .privacy: return " - Privacy Policy"
            case .open: return " - Open in App"
            }
        }
        
        var fileName: String {
            switch self {
            case .main: return ""
            case .terms: return "terms.md"
            case .privacy: return "privacy.md"
            case .open: return ""
            }
        }
        
        var notFoundMessage: String {
            switch self {
            case .main: return "App not found"
            case .terms: return "Terms & Conditions not found for this app."
            case .privacy: return "Privacy Policy not found for this app."
            case .open: return "App not found."
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
        }
    }
    
    // MARK: - Main App Page
    @MainActor private func renderMainPage() -> some HTML {
        VStack(alignment: .leading) {
            if let app = findApp() {
                // Header section with app info
                Section {
                    Grid(alignment: .topLeading) {
                        Image(app.imagePath, description: app.imageDescription)
                            .resizable()
                            .aspectRatio(.square, contentMode: .fit)
                            .frame(width: 132, height: 132)
                            .padding(.trailing, 10)
                            .width(4)
                        
                        VStack(alignment: .leading) {
                            Text(app.title)
                                .font(.title1)
                                .fontWeight(.bold)
                                .horizontalAlignment(.leading)
                            
                            Text(app.subtitle)
                                .font(.title2)
                                .foregroundStyle(.secondary)
                                .padding(.bottom, 5)
                            
                            if !app.platforms.isEmpty {
                                PlatformPillRow(platforms: app.platforms)
                                .padding(.bottom, 10)
                            }
                        }
                        .width(8)
                    }
                    .padding(.bottom)
                    
                    Text(app.description)
                        .font(.body)
                        .padding(.bottom, 10)
                    
                    Text(app.nameOrigin)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 20)
                    
                    // Action buttons
                    HStack {
                        ForEach(app.actions) { action in
                            ActionButton(
                                title: action.title,
                                target: action.target,
                                style: action.style == "primary" ? .primary : .secondary
                            )
                        }
                    }
                    .style(.flexWrap, "wrap")
                    .style(.gap, "0.5rem")
                    .padding(.bottom, 20)

                    if !app.featuredIn.isEmpty {
                        FeaturedInBox(
                            title: "Featured in",
                            mentions: app.featuredIn,
                            quote: app.featuredQuote,
                            quoteSourceTitle: app.featuredQuoteSourceTitle,
                            quoteSourceTarget: app.featuredQuoteSourceTarget
                        )
                        .padding(.bottom, 24)
                    }
                    
                    // Terms, Privacy, and Support links
                    HStack {
                        pillLink("Terms & Conditions", target: "/apps/\(appIdentifier)/terms")
                        pillLink("Privacy Policy", target: "/apps/\(appIdentifier)/privacy")
                        pillLink("Support & Contact", target: "#support-contact")
                    }
                    .style(.flexWrap, "wrap")
                    .style(.gap, "0.5rem")
                }
                .padding(.bottom)
                
                // Features section with sub-sections
                if !app.featureGroups.isEmpty {
                    Section {
                        Text("Features")
                            .font(.title2)
                            .fontWeight(.bold)
                            .horizontalAlignment(.leading)
                            .padding(.bottom)
                        
                        ForEach(app.featureGroups) { group in
                            VStack(alignment: .leading) {
                                Text(group.title)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .horizontalAlignment(.leading)
                                    .padding(.bottom)
                                
                                Grid(alignment: .topLeading) {
                                    ForEach(group.features) { feature in
                                        Card(imageName: feature.imagePath ?? app.imagePath) {
                                            Text(feature.description)
                                                .font(.body)
                                        } header: {
                                            Text(feature.title)
                                                .font(.title4)
                                                .foregroundStyle(.body)
                                        }
                                        .width(4)
                                    }
                                }
                                .padding(.bottom, 30)
                            }
                        }
                    }
                    .padding(.vertical)
                } else {
                    // Fallback to flat features for backward compatibility
                Section {
                    Text("Features")
                        .font(.title2)
                        .fontWeight(.bold)
                        .horizontalAlignment(.leading)
                        .padding(.bottom)
                    
                    Grid(alignment: .topLeading) {
                        ForEach(app.features) { feature in
                            Card(imageName: feature.imagePath ?? app.imagePath) {
                                Text(feature.description)
                                    .font(.body)
                            } header: {
                                Text(feature.title)
                                    .font(.title3)
                                    .foregroundStyle(.body)
                            }
                            .width(4)
                        }
                    }
                }
                .padding(.vertical)
                }
                
                // Why Xarra? section
                if let whySection = app.whySection {
                    Section {
                        Text("Why \(app.title)?")
                            .font(.title2)
                            .fontWeight(.bold)
                            .horizontalAlignment(.leading)
                            .padding(.bottom)
                        
                        Text(whySection)
                            .font(.body)
                    }
                    .padding(.vertical)
                }
                
                // Support & Contact section
                Section {
                    Text("Support & Contact")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.bottom)
                        .horizontalAlignment(.leading)
                    
                    Text(app.supportText)
                        .font(.body)
                        .padding(.bottom)
                        .horizontalAlignment(.leading)
                    
                    HStack {
                        ActionButton(title: "Contact", target: "mailto:\(app.contactEmail)", style: .primary)
                            .horizontalAlignment(.leading)
                    }
                }
                .id("support-contact")
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
    
    // MARK: - Legal Pages
    @MainActor private func renderLegalPage() -> some HTML {
        VStack {
            if let app = findApp() {
                // Header with app info and back link
                Section {
                    VStack(alignment: .leading) {
                        HStack(alignment: .center) {
                            Image(decorative: app.imagePath)
                                .resizable()
                                .aspectRatio(.square, contentMode: .fit)
                                .frame(width: 80, height: 80)
                                .padding(.trailing)
                            
                            VStack(alignment: .leading) {
                                Text("\(app.title)\(pageType.titleSuffix)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Link("← Back to \(app.title)", target: "/apps/\(appIdentifier)")
                                    .style(.textDecoration, "none")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
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
                    Text("Opening \(app.title)…")
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

                    Link("View \(app.title) details on this site", target: "/apps/\(appIdentifier)")
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
    
    private func loadLegalContent() -> String? {
        guard let app = findApp() else { return nil }
        // Use the title without special characters for the folder name
        let folderName = app.title.replacingOccurrences(of: "!", with: "")
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
    
    @MainActor private func pillLink(_ title: String, target: String, emphasis: Bool = false) -> some InlineElement {
        Link(title, target: target)
            .padding(.vertical, .small)
            .padding(.horizontal)
            .cornerRadius(8)
            .style(.textDecoration, "none")
            .style(.backgroundColor, emphasis ? "var(--bs-primary)" : "transparent")
            .style(.color, emphasis ? "var(--bs-secondary)" : "var(--bs-primary)")
            .style(.border, "1px solid var(--bs-primary)")
    }
}
