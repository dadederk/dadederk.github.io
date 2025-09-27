import Foundation
import Ignite

/// Component to display related posts section for Days 365 posts
struct RelatedPostsSection: HTML {
    let relatedPosts: [Days365Data]
    
    @MainActor var body: some HTML {
        if !relatedPosts.isEmpty {
            Section {
                VStack(alignment: .leading, spacing: 16) {
                    // Section heading
                    Text("You may also find interesting...")
                        .font(.title2)
                        .fontWeight(.bold)
                        .horizontalAlignment(.leading)
                    
                    // Related posts grid using existing Days 365 cards
                    Grid(alignment: .topLeading) {
                        ForEach(relatedPosts) { post in
                            Days365AsArticlePreview(post: post)
                                .width(4)
                        }
                    }
                }
                .horizontalAlignment(.leading)
            }
            .padding(.vertical, 32)
        }
    }
}
