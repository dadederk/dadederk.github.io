import Foundation
import Ignite

struct Days365TagPage: StaticPage {
    let tag: String
    
    var title: String { "Tag: \(tag) - #365DaysIOSAccessibility" }
    var path: String { "/365-days-ios-accessibility/tag/\(tag.lowercased().replacingOccurrences(of: " ", with: "-"))" }
    var description: String {
        let count = Days365Loader.posts(withTag: tag).count
        return "Browse \(count) #365DaysIOSAccessibility post\(count == 1 ? "" : "s") tagged \(tag)."
    }
    var image: URL? {
        let taggedImage = Days365Loader.posts(withTag: tag).first(where: { $0.image != nil })?.image
        return SiteMeta.imageURL(taggedImage)
    }
    
    var body: some HTML {
        VStack(alignment: .leading) {
            // Breadcrumb navigation
            Section {
                Link("#365DaysIOSAccessibility", target: "/365-days-ios-accessibility")
                    .foregroundStyle(.primary)
                    .font(.body)
                    .class("text-break")
                    .horizontalAlignment(.leading)
            }
            .horizontalAlignment(.leading)
            .padding(.bottom)
            
            // Page header
            Section {
                HStack(alignment: .bottom) {
                    Text("Tag: \(tag)")
                        .font(.title2)
                        .class("text-break")
                    
                    let posts = Days365Loader.posts(withTag: tag)
                    Text("\(posts.count) post\(posts.count == 1 ? "" : "s")")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                .style(.flexWrap, "wrap")
                .style(.gap, "0.5rem")
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
                        Link(target: "/365-days-ios-accessibility/tag/\(tagName.lowercased().replacingOccurrences(of: " ", with: "-"))") {
                            Badge(tagName)
                                .role(.primary)
                        }
                        .margin(.trailing, 8)
                        .margin(.bottom, 8)
                    }
                }
                .style(.flexWrap, "wrap")
            }
            .padding(.top)
            .border(.gray, edges: .top)
        }
        .horizontalAlignment(.leading)
    }
}
