import Foundation
import Ignite

// Component that replicates ArticlePreview behavior exactly for 365 Days posts
struct Days365AsArticlePreview: HTML {
    let post: Days365Data
    
    @MainActor var body: some HTML {
        // This replicates exactly what ArticlePreview(for: article).articlePreviewStyle(HomeArticlePreviewStyle()) produces
        HomeArticlePreviewStyleFor365Days(post: post)
    }
}

// Exact replica of HomeArticlePreviewStyle but adapted for Days365Data
struct HomeArticlePreviewStyleFor365Days: HTML {
    let post: Days365Data
    
    @MainActor var body: some HTML {
        Card(imageName: post.image) {
            Text(post.excerpt)
                .lineLimit(8)
                .margin(.bottom, .none)
        } header: {
            Text {
                Link(post.title, target: post.path)
            }
            .font(.title2)
        } footer: {
            if !post.tags.isEmpty {
                Section {
                    ForEach(post.tags) { tag in
                        Link(target: post.path(forTag: tag)) {
                            Badge(tag)
                                .role(.primary)
                        }
                        .relationship(.tag)
                        .margin(.trailing)
                    }
                }
                .class("d-flex", "flex-wrap")
                .margin(.top, -5)
            }
        }
    }
}
