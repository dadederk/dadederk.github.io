import Foundation
import Ignite

struct Days365PostPage: StaticPage {
    let post: Days365Data
    
    var title: String { post.title }
    var path: String { post.path }
    
    var body: some HTML {
        VStack(alignment: .leading, spacing: 24) {
            // Breadcrumb navigation
            Section {
                HStack {
                    Link("#365DaysIOSAccessibility", target: "/365-days-ios-accessibility")
                        .foregroundStyle(.primary)
                    
                    Text(" / ")
                        .foregroundStyle(.secondary)
                    
                    Text(post.title)
                        .foregroundStyle(.secondary)
                }
                .font(.body)
            }
            .padding(.bottom)
            
            // Article header
            Section {
                VStack(alignment: .leading, spacing: 16) {
                    Text(post.title)
                        .font(.title1)
                        .fontWeight(.bold)
                    
                    HStack {
                        if !post.author.isEmpty {
                            Text("By \(post.author)")
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .fontWeight(.medium)
                        }
                        
                        Spacer()
                        
                        Text(post.date.formatted(date: .abbreviated, time: .omitted))
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .fontWeight(.medium)
                    }
                    
                }
            }
            .padding(.bottom)
            
            
            // Article content
            Section {
                // Convert markdown content to HTML
                MarkdownRenderer(content: post.content)
            }
            .padding(.bottom)
            
            // Tags section
            if !post.tags.isEmpty {
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Tags")
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        HStack {
                            ForEach(post.tags) { tag in
                                Link(tag, target: "/365-days-ios-accessibility/tag/\(tag.lowercased().replacingOccurrences(of: " ", with: "-"))")
                                    .class("badge", "bg-primary", "text-white", "rounded-pill", "me-2")
                            }
                        }
                        .class("flex-wrap")
                    }
                }
                .padding(.top)
                .border(.gray, edges: .top)
            }
            
            // Navigation to other posts
            Section {
                let allPosts = Days365Loader.loadPosts()
                let currentIndex = allPosts.firstIndex(where: { $0.fileName == post.fileName }) ?? 0
                
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
            .padding(.top)
            .border(.gray, edges: .top)
        }
        .padding(.horizontal)
    }
}
