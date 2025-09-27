import Foundation
import Ignite

/// Component to display related articles section for regular blog posts
struct RelatedArticlesSection: HTML {
    let relatedArticles: [Article]
    
    @MainActor var body: some HTML {
        if !relatedArticles.isEmpty {
            Section {
                VStack(alignment: .leading, spacing: 16) {
                    // Section heading
                    Text("You may also find interesting...")
                        .font(.title2)
                        .fontWeight(.bold)
                        .horizontalAlignment(.leading)
                    
                    // Related articles grid using existing ArticlePreview components
                    Grid(alignment: .topLeading) {
                        ForEach(relatedArticles) { article in
                            ArticlePreview(for: article)
                                .articlePreviewStyle(HomeArticlePreviewStyle())
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

/// Helper functions for finding related articles
extension Article {
    /// Get related articles for a given article
    /// Returns 3 articles: prioritizing specific tags, then falling back to general tags
    static func relatedArticles(for article: Article, from allArticles: [Article], limit: Int = 3) -> [Article] {
        let currentArticlePath = article.path
        
        // Define general tags (fallback)
        let generalTags = ["accessibility", "a11y", "ios"]
        
        // Get all tags from the current article
        let currentArticleTags = Set(article.tags ?? [])
        
        // Separate specific tags from general tags
        let specificTags = currentArticleTags.filter { tag in
            !generalTags.contains { $0.lowercased() == tag.lowercased() }
        }
        
        var relatedArticles: [Article] = []
        var usedArticlePaths = Set([currentArticlePath])
        
        // First, try to get articles from specific tags
        if !specificTags.isEmpty {
            for tag in specificTags {
                if relatedArticles.count >= limit { break }
                
                let articlesWithTag = allArticles.filter { otherArticle in
                    !usedArticlePaths.contains(otherArticle.path) &&
                    (otherArticle.tags?.contains { $0.lowercased() == tag.lowercased() } ?? false)
                }
                .shuffled()
                
                if let randomArticle = articlesWithTag.first {
                    relatedArticles.append(randomArticle)
                    usedArticlePaths.insert(randomArticle.path)
                }
            }
        }
        
        // If we still need more articles, fill with articles from general tags
        if relatedArticles.count < limit {
            let remainingNeeded = limit - relatedArticles.count
            
            for tag in generalTags {
                if relatedArticles.count >= limit { break }
                
                let articlesWithTag = allArticles.filter { otherArticle in
                    !usedArticlePaths.contains(otherArticle.path) &&
                    (otherArticle.tags?.contains { $0.lowercased() == tag.lowercased() } ?? false)
                }
                .shuffled()
                
                let neededFromThisTag = min(remainingNeeded, articlesWithTag.count)
                for i in 0..<neededFromThisTag {
                    if relatedArticles.count >= limit { break }
                    relatedArticles.append(articlesWithTag[i])
                    usedArticlePaths.insert(articlesWithTag[i].path)
                }
            }
        }
        
        // If we still don't have enough, fill with any random articles
        if relatedArticles.count < limit {
            let remainingArticles = allArticles
                .filter { !usedArticlePaths.contains($0.path) }
                .shuffled()
            
            let needed = limit - relatedArticles.count
            for i in 0..<min(needed, remainingArticles.count) {
                relatedArticles.append(remainingArticles[i])
            }
        }
        
        return relatedArticles
    }
}
