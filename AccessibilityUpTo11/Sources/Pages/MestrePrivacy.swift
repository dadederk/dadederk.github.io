import Foundation
import Ignite

struct MestrePrivacy: StaticPage {
    var title = "Mestre - Privacy Policy"
    var path = "/apps/mestre/privacy"
    
    @MainActor var body: some HTML {
        VStack {
            if let app = findApp() {
                // Header with app info and back link
                Section {
                    HStack(alignment: .center) {
                        Image(app.imagePath, description: app.imageDescription)
                            .resizable()
                            .aspectRatio(.square, contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .padding(.trailing)
                        
                        VStack(alignment: .leading) {
                            Text("\(app.title) - Privacy Policy")
                                .font(.title2)
                                .fontWeight(.bold)
                                .horizontalAlignment(.leading)
                            
                            Link("← Back to \(app.title)", target: "/apps/mestre")
                                .class("text-decoration-none")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.bottom)
                
                // Privacy content
                Section {
                    if let privacyContent = loadPrivacyContent() {
                        MarkdownRenderer(content: privacyContent)
                    } else {
                        Text("Privacy Policy not found for this app.")
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical)
            } else {
                // App not found
                Section {
                    Text("App not found")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical)
            }
        }
    }
    
    private func findApp() -> AppItem? {
        let appsData = AppsData.loadContent()
        return appsData.apps.first { app in
            app.title.lowercased() == "mestre"
        }
    }
    
    private func loadPrivacyContent() -> String? {
        let privacyPath = "AppsData/Mestre/privacy.md"
        
        let url = URL(fileURLWithPath: privacyPath)
        guard FileManager.default.fileExists(atPath: url.path) else {
            return nil
        }
        
        do {
            return try String(contentsOf: url)
        } catch {
            print("Error loading privacy content: \(error)")
            return nil
        }
    }
}
