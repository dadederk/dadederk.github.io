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
    /// Returns up to `limit` articles: fill from specific tags first, then general tags, then any articles.
    static func relatedArticles(for article: Article, from allArticles: [Article], limit: Int = 3) -> [Article] {
        let currentArticlePath = article.path
        
        // Define general tags (fallback)
        let generalTagNames = ["accessibility", "a11y", "ios"]
        let generalTags = Set(generalTagNames.map { $0.lowercased() })
        
        // Get all tags from the current article
        let currentArticleTags = Set((article.tags ?? []).map { $0.lowercased() })
        
        // Separate specific tags from general tags
        let specificTags = currentArticleTags.filter { !generalTags.contains($0) }
        
        var relatedArticles: [Article] = []
        var usedArticlePaths = Set([currentArticlePath])
        
        func appendFromCandidates(_ candidates: [Article]) {
            for candidate in Self.prioritizeRelatedCandidates(candidates) {
                if relatedArticles.count >= limit { break }
                guard !usedArticlePaths.contains(candidate.path) else { continue }
                relatedArticles.append(candidate)
                usedArticlePaths.insert(candidate.path)
            }
        }
        
        // First, fill as many slots as possible from articles sharing specific tags
        if !specificTags.isEmpty {
            let specificMatches = allArticles.filter { candidate in
                guard !usedArticlePaths.contains(candidate.path) else { return false }
                let candidateTags = Set((candidate.tags ?? []).map { $0.lowercased() })
                return !specificTags.isDisjoint(with: candidateTags)
            }
            
            let byScore = Dictionary(grouping: specificMatches) { candidate in
                let candidateTags = Set((candidate.tags ?? []).map { $0.lowercased() })
                return specificTags.intersection(candidateTags).count
            }
            
            for score in byScore.keys.sorted(by: >) {
                if relatedArticles.count >= limit { break }
                appendFromCandidates(byScore[score] ?? [])
            }
        }
        
        // If we still need more articles, fill from general tags the current article actually has
        if relatedArticles.count < limit {
            let applicableGeneralTags = generalTagNames.filter { name in
                currentArticleTags.contains(name.lowercased())
            }
            
            for tag in applicableGeneralTags {
                if relatedArticles.count >= limit { break }
                
                let articlesWithTag = allArticles.filter { otherArticle in
                    !usedArticlePaths.contains(otherArticle.path) &&
                    (otherArticle.tags?.contains { $0.lowercased() == tag.lowercased() } ?? false)
                }
                appendFromCandidates(articlesWithTag)
            }
        }
        
        // If we still don't have enough, fill with any remaining articles
        if relatedArticles.count < limit {
            let remainingArticles = allArticles.filter { !usedArticlePaths.contains($0.path) }
            appendFromCandidates(remainingArticles)
        }
        
        return relatedArticles
    }
    
    private static func prioritizeRelatedCandidates(_ articles: [Article]) -> [Article] {
        articles.shuffled()
    }
}
