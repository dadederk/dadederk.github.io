import Foundation
import Ignite

struct Blog: StaticPage {
    var title = "iOS Accessibility Articles"
    var path = "/blog"
    var description = "Long-form articles on building accessible iOS apps, inclusive design decisions, and practical engineering techniques."
    var image: URL? { SiteMeta.imageURL(nil) }
    
    @Environment(\.articles) var articles
    
    var body: some HTML {
        VStack(alignment: .leading) {
            // Page heading
            Text("All Our Long-form Articles About iOS Accessibility")
                .font(.title1)
                .fontWeight(.bold)
                .horizontalAlignment(.leading)
                .padding(.bottom, 10)

            Text("Long-form articles about accessibility in SwiftUI and UIKit, VoiceOver, testing, inclusive games, and lessons learned while building apps for Apple platforms.")
                .font(.body)
                .foregroundStyle(.secondary)
                .horizontalAlignment(.leading)
                .padding(.bottom)
            
            // Blog posts list - grid layout with consistent ArticlePreview components
            Section {
                let allArticles = articles.all.sorted(by: \.date, order: .reverse)
                
                if !allArticles.isEmpty {
                    Grid(alignment: .topLeading) {
                        ForEach(allArticles) { article in
                            ArticlePreview(for: article)
                                .articlePreviewStyle(HomeArticlePreviewStyle())
                                .width(4)
                        }
                    }
                } else {
                    Text("No blog posts available yet.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .padding(.vertical)
                }
            }
        }
    }
}
