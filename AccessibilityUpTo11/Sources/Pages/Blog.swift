import Foundation
import Ignite

struct Blog: StaticPage {
    var title = "Blog"
    var path = "/blog"
    
    @Environment(\.articles) var articles
    
    var body: some HTML {
        VStack(alignment: .leading) {
            // Page heading
            Text("All Our Long-form Articles About iOS Accessibility")
                .font(.title1)
                .fontWeight(.bold)
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

