import Foundation
import Ignite

struct Days365: StaticPage {
    var title = "#365DaysIOSAccessibility"
    var path = "/365-days-ios-accessibility"
    
    var body: some HTML {
        VStack(alignment: .leading) {
            // Page heading
            Text("Tips and tricks to build accessible iOS apps")
                .font(.title1)
                .fontWeight(.bold)
                .horizontalAlignment(.leading)
                .padding(.bottom)
            
            // Page header with RSS link
            Section {
                // Desktop layout: HStack with title2
                HStack(alignment: .bottom) {
                    Text("#365DaysIOSAccessibility")
                        .font(.title2)
                    
                    Link("RSS Feed", target: "/365-days-feed.rss")
                        .class("btn", "btn-primary")
                        .font(.body)
                }
                .class("d-none", "d-md-flex")
                .padding(.bottom)
                
                // Mobile layout: VStack with title4
                VStack(alignment: .leading, spacing: 8) {
                    Text("#365DaysIOSAccessibility")
                        .font(.title4)
                    
                    Link("RSS Feed", target: "/365-days-feed.rss")
                        .class("btn", "btn-primary")
                        .font(.body)
                }
                .class("d-md-none")
                .padding(.bottom)
                
                Text("A year-long journey exploring iOS accessibility, one day at a time. Each post shares practical insights, tips, and techniques to make your iOS apps more accessible.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .padding([.bottom, .leading, .trailing])
                
                let allPosts = Days365Loader.loadPosts()
                let postsPerPage = 15
                let currentPage = 1
                let startIndex = (currentPage - 1) * postsPerPage
                let endIndex = min(startIndex + postsPerPage, allPosts.count)
                let postsToShow = Array(allPosts[startIndex..<endIndex])
                let totalPages = (allPosts.count + postsPerPage - 1) / postsPerPage
                
                if !postsToShow.isEmpty {
                    Grid(alignment: .topLeading) {
                        ForEach(postsToShow) { post in
                            Days365AsArticlePreview(post: post)
                                .width(4)
                        }
                    }
                    
                    // Pagination controls
                    if totalPages > 1 {
                        Section {
                            VStack(spacing: 16) {
                                // Pagination info
                                Text("Showing \(startIndex + 1)-\(endIndex) of \(allPosts.count) posts")
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                                
                                // Pagination buttons
                                HStack(spacing: 12) {
                                    // Previous button (disabled on first page)
                                    Text("← Previous")
                                        .class("btn", "btn-outline-secondary", "disabled")
                                        .foregroundStyle(.secondary)
                                    
                                    Spacer()
                                    
                                    // Page indicator
                                    Text("Page \(currentPage) of \(totalPages)")
                                        .font(.body)
                                        .foregroundStyle(.secondary)
                                    
                                    Spacer()
                                    
                                    // Next button
                                    if totalPages > 1 {
                                        Link("Next →", target: "/365-days-ios-accessibility/page-2")
                                            .class("btn", "btn-outline-secondary")
                                    } else {
                                        Text("Next →")
                                            .class("btn", "btn-outline-secondary", "disabled")
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                        .padding(.top)
                    }
                } else {
                    Text("No 365 days posts available yet.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .padding(.vertical)
                }
            }
            .padding(.vertical)
        }
        .horizontalAlignment(.leading)
    }
}


/// Paginated version of the 365 Days page
struct Days365Page: StaticPage {
    let pageNumber: Int
    
    var title: String { 
        pageNumber == 1 ? "#365DaysIOSAccessibility" : "#365DaysIOSAccessibility - Page \(pageNumber)"
    }
    var path: String { 
        pageNumber == 1 ? "/365-days-ios-accessibility" : "/365-days-ios-accessibility/page-\(pageNumber)"
    }
    
    var body: some HTML {
        VStack(alignment: .leading) {
            // Page heading
            Text("Tips and tricks to build accessible iOS apps")
                .font(.title1)
                .fontWeight(.bold)
                .horizontalAlignment(.leading)
                .padding(.bottom)
            
            // Page header with RSS link
            Section {
                // Desktop layout: HStack with title2
                HStack(alignment: .bottom) {
                    Text("#365DaysIOSAccessibility")
                        .font(.title2)
                    
                    Link("RSS Feed", target: "/365-days-feed.rss")
                        .class("btn", "btn-primary")
                        .font(.body)
                }
                .class("d-none", "d-md-flex")
                .padding(.bottom)
                
                // Mobile layout: VStack with title4
                VStack(alignment: .leading, spacing: 8) {
                    Text("#365DaysIOSAccessibility")
                        .font(.title4)
                    
                    Link("RSS Feed", target: "/365-days-feed.rss")
                        .class("btn", "btn-primary")
                        .font(.body)
                }
                .class("d-md-none")
                .padding(.bottom)
                
                Text("A year-long journey exploring iOS accessibility, one day at a time. Each post shares practical insights, tips, and techniques to make your iOS apps more accessible.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .padding(.bottom)
                
                let allPosts = Days365Loader.loadPosts()
                let postsPerPage = 15
                let currentPage = pageNumber
                let startIndex = (currentPage - 1) * postsPerPage
                let endIndex = min(startIndex + postsPerPage, allPosts.count)
                let postsToShow = Array(allPosts[startIndex..<endIndex])
                let totalPages = (allPosts.count + postsPerPage - 1) / postsPerPage
                
                if !postsToShow.isEmpty {
                    Grid(alignment: .topLeading) {
                        ForEach(postsToShow) { post in
                            Days365AsArticlePreview(post: post)
                                .width(4)
                        }
                    }
                    
                    // Pagination controls
                    if totalPages > 1 {
                        Section {
                            VStack(spacing: 16) {
                                // Pagination info
                                Text("Showing \(startIndex + 1)-\(endIndex) of \(allPosts.count) posts")
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                                
                                // Pagination buttons
                                HStack(spacing: 12) {
                                    // Previous button
                                    if currentPage > 1 {
                                        let prevPage = currentPage - 1
                                        let prevPath = prevPage == 1 ? "/365-days-ios-accessibility" : "/365-days-ios-accessibility/page-\(prevPage)"
                                        Link("← Previous", target: prevPath)
                                            .class("btn", "btn-outline-secondary")
                                    } else {
                                        Text("← Previous")
                                            .class("btn", "btn-outline-secondary", "disabled")
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    // Page indicator
                                    Text("Page \(currentPage) of \(totalPages)")
                                        .font(.body)
                                        .foregroundStyle(.secondary)
                                    
                                    Spacer()
                                    
                                    // Next button
                                    if currentPage < totalPages {
                                        let nextPage = currentPage + 1
                                        Link("Next →", target: "/365-days-ios-accessibility/page-\(nextPage)")
                                            .class("btn", "btn-outline-secondary")
                                    } else {
                                        Text("Next →")
                                            .class("btn", "btn-outline-secondary", "disabled")
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                        .padding(.top)
                    }
                } else {
                    Text("No 365 days posts available yet.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .padding(.vertical)
                }
            }
            .padding(.vertical)
        }
        .horizontalAlignment(.leading)
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
