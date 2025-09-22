import Foundation
import Ignite

struct Days365TagPage: StaticPage {
    let tag: String
    
    var title: String { "Tag: \(tag) - #365DaysIOSAccessibility" }
    var path: String { "/365-days-ios-accessibility/tag/\(tag.lowercased().replacingOccurrences(of: " ", with: "-"))" }
    
    var body: some HTML {
        VStack(alignment: .leading, spacing: 24) {
            // Breadcrumb navigation
            Section {
                HStack {
                    Link("#365DaysIOSAccessibility", target: "/365-days-ios-accessibility")
                        .foregroundStyle(.primary)
                    
                    Text(" / ")
                        .foregroundStyle(.secondary)
                    
                    Text("Tag: \(tag)")
                        .foregroundStyle(.secondary)
                }
                .font(.body)
            }
            .padding(.bottom)
            
            // Page header
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Tag: \(tag)")
                        .font(.title1)
                        .fontWeight(.bold)
                    
                    let posts = Days365Loader.posts(withTag: tag)
                    Text("\(posts.count) post\(posts.count == 1 ? "" : "s") found")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.bottom)
            
            // Posts with this tag
            Section {
                let posts = Days365Loader.posts(withTag: tag)
                
                if !posts.isEmpty {
                    Grid(alignment: .topLeading) {
                        ForEach(posts) { post in
                            Days365Card(post: post)
                                .width(4) // Bootstrap col-md-4 equivalent
                        }
                    }
                } else {
                    Text("No posts found with the tag \"\(tag)\".")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .horizontalAlignment(.center)
                        .padding(.vertical)
                }
            }
            
            // All tags section
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Text("All Tags")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    HStack {
                        let allTags = Days365Loader.allTags()
                        ForEach(allTags) { tagName in
                            Link(tagName, target: "/365-days-ios-accessibility/tag/\(tagName.lowercased().replacingOccurrences(of: " ", with: "-"))")
                                .class("badge", "bg-primary", "text-white", "rounded-pill", "me-2")
                        }
                    }
                    .class("flex-wrap")
                }
            }
            .padding(.top)
            .border(.gray, edges: .top)
        }
        .padding(.horizontal)
    }
}
