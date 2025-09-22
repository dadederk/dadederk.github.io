import Foundation
import Ignite

/// Generator for all 365 Days iOS Accessibility static pages
struct Days365StaticPages {
    
    /// Generate all static pages for 365 days content
    static func generateAllPages() -> [any StaticPage] {
        var pages: [any StaticPage] = []
        
        // Load all posts
        let allPosts = Days365Loader.loadPosts()
        
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
