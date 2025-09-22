import Foundation
import Ignite

struct Days365: StaticPage {
    var title = "#365DaysIOSAccessibility"
    var path = "/365-days-ios-accessibility"
    
    var body: some HTML {
        VStack(spacing: 24) {
            // Page header with RSS link
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Text("#365DaysIOSAccessibility")
                        .font(.title1)
                        .fontWeight(.bold)
                        .horizontalAlignment(.leading)
                    
                    Text("A year-long journey exploring iOS accessibility, one day at a time. Each post shares practical insights, tips, and techniques to make your iOS apps more accessible.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .horizontalAlignment(.leading)
                    
                    HStack {
                        Link("RSS Feed", target: "/365-days-feed.rss")
                            .class("btn", "btn-primary", "me-3")
                        
                        Text("Subscribe to get the latest 365 days posts")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top)
                }
                .horizontalAlignment(.leading)
            }
            .padding(.vertical)
            .horizontalAlignment(.leading)
            
            // Posts grid using Ignite's Grid component (similar to Home page)
            Section {
                let allPosts = Days365Loader.loadPosts()
                
                if !allPosts.isEmpty {
                    Grid(alignment: .topLeading) {
                        ForEach(allPosts) { post in
                            Days365Card(post: post)
                                .width(4) // Bootstrap col-md-4 equivalent
                        }
                    }
                } else {
                    Text("No 365 days posts available yet.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .horizontalAlignment(.center)
                        .padding(.vertical)
                }
            }
        }
        .padding(.horizontal)
    }
}

/// Custom card component for 365 days posts matching Home page style
struct Days365Card: HTML {
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
                    ForEach(Array(post.tags.prefix(5))) { tag in
                        Link(tag, target: "/365-days-ios-accessibility/tag/\(tag.lowercased().replacingOccurrences(of: " ", with: "-"))")
                            .class("badge", "bg-primary", "text-white", "rounded-pill", "me-2")
                    }
                }
                .margin(.top, -5)
            }
        }
    }
}

// Extension to chunk arrays for grid layout
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
