import Foundation
import Ignite

/// Generator for all 365 Days iOS Accessibility static pages
struct Days365StaticPages {
    
    /// Generate all static pages for 365 days content
    static func generateAllPages() -> [any StaticPage] {
        var pages: [any StaticPage] = []
        
        // Load all posts
        let allPosts = Days365Loader.loadPosts()
        
        // Generate paginated main pages
        let postsPerPage = 15
        let totalPages = (allPosts.count + postsPerPage - 1) / postsPerPage
        
        for pageNumber in 1...totalPages {
            pages.append(Days365Page(pageNumber: pageNumber))
        }
        
        // Generate individual post pages
        for post in allPosts {
            pages.append(Days365PostPage(post: post))
        }
        
        // Generate tag pages
        let allTags = Days365Loader.allTags()
        for tag in allTags {
            pages.append(Days365TagPage(tag: tag))
        }
        
        return pages
    }
}
