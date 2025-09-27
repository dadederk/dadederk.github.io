import Foundation
import Ignite

struct Days365TagPage: StaticPage {
    let tag: String
    
    var title: String { "Tag: \(tag) - #365DaysIOSAccessibility" }
    var path: String { "/365-days-ios-accessibility/tag/\(tag.lowercased().replacingOccurrences(of: " ", with: "-"))" }
    
    var body: some HTML {
        VStack(alignment: .leading) {
            // Breadcrumb navigation
            Section {
                Link("#365DaysIOSAccessibility", target: "/365-days-ios-accessibility")
                    .foregroundStyle(.primary)
                    .font(.body)
                    .horizontalAlignment(.leading)
            }
            .horizontalAlignment(.leading)
            .padding(.bottom)
            
                    // Page header
                    Section {
                        // Desktop layout: HStack with title2
                        HStack(alignment: .bottom) {
                            Text("Tag: \(tag)")
                                .font(.title2)
                            
                            let posts = Days365Loader.posts(withTag: tag)
                            Text("\(posts.count) post\(posts.count == 1 ? "" : "s")")
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }
                        .class("d-none", "d-md-flex")
                        .padding(.bottom)
                        
                        // Mobile layout: VStack with title4
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tag: \(tag)")
                                .font(.title4)
                            
                            let posts = Days365Loader.posts(withTag: tag)
                            Text("\(posts.count) post\(posts.count == 1 ? "" : "s")")
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }
                        .class("d-md-none")
                        .padding(.bottom)
                
                let allPosts = Days365Loader.posts(withTag: tag)
                let postsPerPage = 12 // Slightly fewer for tag pages
                let postsToShow = Array(allPosts.prefix(postsPerPage))
                
                if !postsToShow.isEmpty {
                        Grid(alignment: .topLeading) {
                            ForEach(postsToShow) { post in
                                Days365AsArticlePreview(post: post)
                                    .width(4)
                            }
                        }
                    
                    // Show pagination info if there are more posts
                    if allPosts.count > postsPerPage {
                        Section {
                            Text("Showing \(postsToShow.count) of \(allPosts.count) posts")
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .padding(.top)
                        }
                        .padding(.horizontal)
                    }
                } else {
                    Text("No posts found with the tag \"\(tag)\".")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .padding(.vertical)
                }
            }
            .padding(.bottom)
            
            // All tags section
            Section {
                Text("All Tags")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.bottom)
                
                HStack {
                    let allTags = Days365Loader.allTags()
                    ForEach(allTags) { tagName in
                        Link(tagName, target: "/365-days-ios-accessibility/tag/\(tagName.lowercased().replacingOccurrences(of: " ", with: "-"))")
                            .class("badge", "bg-primary", "text-white", "rounded-pill", "me-2", "mb-2")
                    }
                }
                .class("flex-wrap")
            }
            .padding(.top)
            .border(.gray, edges: .top)
        }
        .horizontalAlignment(.leading)
    }
}
