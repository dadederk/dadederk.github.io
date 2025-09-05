import Foundation
import Ignite

struct Home: StaticPage {
    var title = "Home"
    
    @Environment(\.articles) var articles

    var body: some HTML {
        VStack {
            
            // Recent Posts section
            Section {
                HStack(alignment: .bottom) {
                    Text("Recent Posts")
                        .font(.title2)
                    
                    Link("See All", target: "/blog")
                        .font(.body)
                }
                .padding(.bottom)
                
                let recentArticles = articles.all.sorted(by: \.date, order: .reverse).prefix(20)
                
                if !recentArticles.isEmpty {
                    Grid(alignment: .topLeading) {
                        ForEach(recentArticles) { article in
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
            .padding(.vertical)
        }
    }
}

// Custom article preview style for Home page that limits description to ~8 lines
struct HomeArticlePreviewStyle: ArticlePreviewStyle {
    @MainActor func body(content: Article) -> any HTML {
        Card(imageName: content.image) {
            Text(content.description)
                .lineLimit(8)
                .margin(.bottom, .none)
        } header: {
            Text {
                Link(content)
            }
            .font(.title2)
        } footer: {
            let tagLinks = content.tagLinks()
            
            if let tagLinks {
                Section {
                    ForEach(tagLinks) { link in
                        link
                            .padding([.trailing])
                    }
                }
                .margin(.top, -5)
            }
        }
    }
}
