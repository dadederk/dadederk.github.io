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
                    VStack(alignment: .leading) {
                        HStack(alignment: .top) {
                            Image(app.imagePath, description: app.imageDescription)
                                .resizable()
                                .aspectRatio(.square, contentMode: .fit)
                                .frame(width: 100, height: 100)
                                .padding()
                            
                            VStack(alignment: .leading) {
                                Text(app.title)
                                    .font(.title1)
                                    .fontWeight(.bold)
                                    .horizontalAlignment(.leading)
                                
                                Text(app.subtitle)
                                    .font(.title2)
                                    .foregroundStyle(.secondary)
                                    .padding(.bottom, 10)
                            }
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
                        .padding(.bottom, 20)
                        
                        // Terms, Privacy, and Support links
                        HStack {
                            Link("Terms & Conditions", target: "/apps/\(appIdentifier)/terms")
                                .class("btn btn-outline-secondary")
                            
                            Link("Privacy Policy", target: "/apps/\(appIdentifier)/privacy")
                                .class("btn btn-outline-secondary")
                            
                            Link("Support & Contact", target: "#support-contact")
                                .class("btn btn-outline-secondary")
                        }
                    }
                    .class("d-none d-md-flex") // Show HStack on medium+ screens
                    
                    // Mobile layout - VStack
                    VStack(alignment: .leading) {
                        Image(app.imagePath, description: app.imageDescription)
                            .resizable()
                            .aspectRatio(.square, contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .padding()
                        
                        VStack(alignment: .leading) {
                            Text(app.title)
                                .font(.title1)
                                .fontWeight(.bold)
                            
                            Text(app.subtitle)
                                .font(.title2)
                                .foregroundStyle(.secondary)
                                .padding(.bottom, 10)
                            
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
                            .padding(.bottom, 20)
                            
                            // Terms, Privacy, and Support links
                            VStack(alignment: .leading) {
                                Link("Terms & Conditions", target: "/apps/\(appIdentifier)/terms")
                                    .class("btn btn-outline-secondary mb-2")
                                
                                Link("Privacy Policy", target: "/apps/\(appIdentifier)/privacy")
                                    .class("btn btn-outline-secondary mb-2")
                                
                                Link("Support & Contact", target: "#support-contact")
                                    .class("btn btn-outline-secondary")
                            }
                        }
                    }
                    .class("d-md-none") // Show VStack on small screens only
                }
                .padding(.vertical)
                
                // Features section with grid
                Section {
                    Text("Features")
                        .font(.title2)
                        .fontWeight(.bold)
                        .horizontalAlignment(.leading)
                        .padding(.bottom)
                    
                    Grid(alignment: .topLeading) {
                        ForEach(app.features) { feature in
                            Card {
                                VStack(alignment: .leading) {
                                    if let imagePath = feature.imagePath {
                                        Image(imagePath, description: feature.imageDescription ?? "Feature screenshot")
                                            .resizable()
                                            .aspectRatio(.square, contentMode: .fit)
                                            .frame(height: 150)
                                            .padding(.bottom)
                                    }
                                    
                                    Text(feature.title)
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .padding(.bottom, 5)
                                    
                                    Text(feature.description)
                                        .font(.body)
                                }
                            }
                            .width(4)
                        }
                    }
                }
                .padding(.vertical)
                
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
                        Link("Contact", target: "mailto:\(app.contactEmail)")
                            .horizontalAlignment(.leading)
                            .class("btn btn-primary")
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
                                    .class("text-decoration-none")
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
        return appsData.apps.first { app in
            app.title.lowercased() == appIdentifier.lowercased()
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
}

