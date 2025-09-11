import Foundation
import Ignite

struct MestreTerms: StaticPage {
    var title = "Mestre - Terms & Conditions"
    var path = "/apps/mestre/terms"
    
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
                            Text("\(app.title) - Terms & Conditions")
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
                
                // Terms content
                Section {
                    if let termsContent = loadTermsContent() {
                        MarkdownRenderer(content: termsContent)
                    } else {
                        Text("Terms & Conditions not found for this app.")
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
    
    private func loadTermsContent() -> String? {
        let termsPath = "AppsData/Mestre/terms.md"
        
        let url = URL(fileURLWithPath: termsPath)
        guard FileManager.default.fileExists(atPath: url.path) else {
            return nil
        }
        
        do {
            return try String(contentsOf: url)
        } catch {
            print("Error loading terms content: \(error)")
            return nil
        }
    }
}
