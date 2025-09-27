import Foundation
import Ignite

struct Days365PostPage: StaticPage {
    let post: Days365Data
    
    var title: String { post.title }
    var path: String { post.path }
    @MainActor var body: some HTML {
        VStack(alignment: .leading) {
            // Breadcrumb navigation
            Section {
                Link("#365DaysIOSAccessibility", target: "/365-days-ios-accessibility")
                    .foregroundStyle(.primary)
                    .font(.body)
                    .horizontalAlignment(.leading)
            }
            .horizontalAlignment(.leading)
            
            // Article header with title and metadata
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    // Title
                    Text(post.title)
                        .font(.title1)
                        .fontWeight(.bold)
                        .horizontalAlignment(.leading)
                    
                    // Date
                    Text(post.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .horizontalAlignment(.leading)
                    
                    // Tags (clickable)
                    if !post.tags.isEmpty {
                        HStack(spacing: 8) {
                            ForEach(post.tags) { tag in
                                Link(tag, target: "/365-days-ios-accessibility/tag/\(tag.lowercased().replacingOccurrences(of: " ", with: "-"))")
                                    .class("badge", "bg-primary", "text-white", "rounded-pill", "me-2")
                            }
                        }
                        .class("flex-wrap")
                        .horizontalAlignment(.leading)
                    }
                    
                    // Article metadata
                    if !post.author.isEmpty {
                        HStack {
                            Text("By ")
                                .font(.body)
                                .foregroundStyle(.secondary)
                            
                            Link(post.author, target: "/about")
                                .font(.body)
                                .foregroundStyle(.primary)
                        }
                        .horizontalAlignment(.leading)
                    }
                }
                .horizontalAlignment(.leading)
            }
            .padding(.vertical, 24)
            
            // Article content
            Section {
                MarkdownRenderer(content: post.content)
                    .horizontalAlignment(.leading)
                    .padding(.horizontal)
            }
            
            // Related posts section
            let relatedPosts = Days365Loader.relatedPosts(for: post)
            RelatedPostsSection(relatedPosts: relatedPosts)
            
            // Navigation to other posts
            Section {
                let allPosts = Days365Loader.loadPosts()
                let currentIndex = allPosts.firstIndex(where: { $0.fileName == post.fileName }) ?? 0
                
                Divider()
                    .padding(.top)
                
                HStack {
                    // Previous post (newer)
                    if currentIndex > 0 {
                        let previousPost = allPosts[currentIndex - 1]
                        Link("← Day \(previousPost.dayNumber)", target: previousPost.path)
                            .class("btn", "btn-outline-secondary")
                    } else {
                        Spacer()
                    }
                    
                    Spacer()
                    
                    // Next post (older)
                    if currentIndex < allPosts.count - 1 {
                        let nextPost = allPosts[currentIndex + 1]
                        Link("Day \(nextPost.dayNumber) →", target: nextPost.path)
                            .class("btn", "btn-outline-secondary")
                    }
                }
            }
            .padding(.bottom)
        }
        .horizontalAlignment(.leading)
    }
}
