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
        
        var pathSegment: String {
            switch self {
            case .main: return ""
            case .terms: return "/terms"
            case .privacy: return "/privacy"
            }
        }
        
        var titleSuffix: String {
            switch self {
            case .main: return ""
            case .terms: return " - Terms & Conditions"
            case .privacy: return " - Privacy Policy"
            }
        }
        
        var fileName: String {
            switch self {
            case .main: return ""
            case .terms: return "terms.md"
            case .privacy: return "privacy.md"
            }
        }
        
        var notFoundMessage: String {
            switch self {
            case .main: return "App not found"
            case .terms: return "Terms & Conditions not found for this app."
            case .privacy: return "Privacy Policy not found for this app."
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
    
    @MainActor var body: some HTML {
        switch pageType {
        case .main:
            renderMainPage()
        case .terms, .privacy:
            renderLegalPage()
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
                            .frame(width: 100, height: 100)
                            .padding()
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
                                HStack(spacing: 4) {
                                    ForEach(app.platforms) { platform in
                                        Text(platform)
                                            .font(.body)
                                            .fontWeight(.medium)
                                            .foregroundStyle(.secondary)
                                            .padding(.horizontal, 4)
                                            .padding(.vertical, 4)
                                            .border(.gray)
                                            .style(.borderColor, "var(--bs-border-color)")
                                            .cornerRadius(4)
                                    }
                                }
                                .style(.flexWrap, "wrap")
                                .style(.gap, "0.25rem")
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
                    
                    // Terms, Privacy, and Support links
                    HStack {
                        pillLink("Terms & Conditions", target: "/apps/\(appIdentifier)/terms")
                        pillLink("Privacy Policy", target: "/apps/\(appIdentifier)/privacy")
                        pillLink("Support & Contact", target: "#support-contact")
                    }
                    .style(.flexWrap, "wrap")
                    .style(.gap, "0.5rem")
                }
                .padding(.vertical)
                
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
                                        Card {
                                            VStack(alignment: .leading, spacing: 0) {
                                                // Image at top, extends to card edges
                                                Image(
                                                    feature.imagePath ?? app.imagePath,
                                                    description: feature.imageDescription ?? app.imageDescription
                                                )
                                                .resizable()
                                                .aspectRatio(16/9, contentMode: .fit)
                                                
                                                // Text content with padding
                                                VStack(alignment: .leading, spacing: 0) {
                                                    Text(feature.title)
                                                        .font(.title4)
                                                        .fontWeight(.bold)
                                                        .padding(.top)
                                                        .padding(.bottom, 5)
                                                    
                                                    Text(feature.description)
                                                        .font(.body)
                                                }
                                                .padding(.horizontal)
                                                .padding(.bottom)
                                            }
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
                            Card {
                                VStack(alignment: .leading, spacing: 0) {
                                    // Image at top, extends to card edges
                                    Image(
                                        feature.imagePath ?? app.imagePath,
                                        description: feature.imageDescription ?? app.imageDescription
                                    )
                                    .resizable()
                                    .aspectRatio(16/9, contentMode: .fit)
                                    
                                    // Text content with padding
                                    VStack(alignment: .leading, spacing: 0) {
                                        Text(feature.title)
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .padding(.top)
                                            .padding(.bottom, 5)
                                        
                                        Text(feature.description)
                                            .font(.body)
                                    }
                                    .padding(.horizontal)
                                    .padding(.bottom)
                                }
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
                .padding(.top)
                
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
        let contentPath = "AppsData/\(app.title)/\(pageType.fileName)"
        
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
