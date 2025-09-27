import Foundation
import Ignite

struct Home: StaticPage {
    var title = "Home"
    
    @Environment(\.articles) var articles

    var body: some HTML {
        VStack {
            // Main page heading
            Text("Developing Accessible iOS Apps")
                .font(.title1)
                .fontWeight(.bold)
                .horizontalAlignment(.leading)
                .padding(.bottom)
            
            // Recent Posts section (3 most recent)
            Section {
                // Desktop layout: HStack with title2
                HStack(alignment: .bottom) {
                    Text("Posts")
                        .font(.title2)
                    
                    Link("See All", target: "/blog")
                        .font(.body)
                }
                .class("d-none", "d-md-flex")
                .padding(.bottom)
                
                // Mobile layout: VStack with title4
                VStack(alignment: .leading, spacing: 8) {
                    Text("Posts")
                        .font(.title4)
                    
                    Link("See All", target: "/blog")
                        .font(.body)
                }
                .class("d-md-none")
                .padding(.bottom)
                
                let recentArticles = articles.all.sorted(by: \.date, order: .reverse).prefix(3)
                
                if !recentArticles.isEmpty {
                    Grid(alignment: .topLeading) {
                        ForEach(recentArticles) { article in
                            ArticlePreview(for: article)
                                .articlePreviewStyle(HomeArticlePreviewStyle())
                                .width(4)
                        }
                    }
                } else {
                    Text("No blog posts available yet.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .padding(.vertical)
                }
            }
            .padding(.vertical)
            
            Divider()
            
            // Recent Collaborations section (3 most recent from More Content)
            Section {
                // Desktop layout: HStack with title2
                HStack(alignment: .bottom) {
                    Text("Collaborations")
                        .font(.title2)
                    
                    Link("See All", target: "/more-content")
                        .font(.body)
                }
                .class("d-none", "d-md-flex")
                .padding(.bottom)
                
                // Mobile layout: VStack with title4
                VStack(alignment: .leading, spacing: 8) {
                    Text("Collaborations")
                        .font(.title4)
                    
                    Link("See All", target: "/more-content")
                        .font(.body)
                }
                .class("d-md-none")
                .padding(.bottom)
                
                // Get the 3 most recent content items (already sorted by date)
                let allContentItems = MarkdownContentLoader.loadAllContentItems()
                    .prefix(3)
                
                if !allContentItems.isEmpty {
                    Grid(alignment: .topLeading) {
                        ForEach(allContentItems) { contentItem in
                            if let imagePath = contentItem.imagePath, let imageDescription = contentItem.imageDescription {
                                ContentCard(
                                    title: contentItem.title,
                                    subtitle: contentItem.subtitle,
                                    description: contentItem.description,
                                    additionalInfo: contentItem.publisher,
                                    imagePath: imagePath,
                                    imageDescription: imageDescription,
                                    actions: contentItem.actions?.map { action in
                                        ActionButton(
                                            title: action["title"] ?? "",
                                            target: action["target"] ?? "",
                                            style: action["style"] == "primary" ? .primary : .secondary
                                        )
                                    } ?? []
                                )
                                .width(4)
                            } else {
                                ContentCard(
                                    title: contentItem.title,
                                    subtitle: contentItem.subtitle,
                                    description: contentItem.description,
                                    additionalInfo: contentItem.publisher,
                                    actions: contentItem.actions?.map { action in
                                        ActionButton(
                                            title: action["title"] ?? "",
                                            target: action["target"] ?? "",
                                            style: action["style"] == "primary" ? .primary : .secondary
                                        )
                                    } ?? []
                                )
                                .width(4)
                            }
                        }
                    }
                } else {
                    Text("No collaborations available yet.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .padding(.vertical)
                }
            }
            .padding(.vertical)
            
            Divider()
            
            // Recent #365DaysIOSAccessibility section (3 most recent)
            Section {
                // Desktop layout: HStack with title2
                HStack(alignment: .bottom) {
                    Text("#365DaysIOSAccessibility")
                        .font(.title2)
                    
                    Link("See All", target: "/365-days-ios-accessibility")
                        .font(.body)
                }
                .class("d-none", "d-md-flex")
                .padding(.bottom)
                
                // Mobile layout: VStack with title4
                VStack(alignment: .leading, spacing: 8) {
                    Text("#365DaysIOSAccessibility")
                        .font(.title4)
                    
                    Link("See All", target: "/365-days-ios-accessibility")
                        .font(.body)
                }
                .class("d-md-none")
                .padding(.bottom)
                
                let recent365Posts = Days365Loader.loadPosts().prefix(3)
                
                if !recent365Posts.isEmpty {
                    Grid(alignment: .topLeading) {
                        ForEach(recent365Posts) { post in
                            Days365AsArticlePreview(post: post)
                                .width(4)
                        }
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
    }
}

// Custom article preview style for Home page that limits description to ~8 lines
struct HomeArticlePreviewStyle: ArticlePreviewStyle {
    @MainActor func body(content: Article) -> any HTML {
        Card(imageName: content.image) {
            Text(content.description)
                .lineLimit(8)
                .margin(.bottom, .none)
        } header: {
            Text {
                Link(content)
            }
            .font(.title2)
        } footer: {
            let tagLinks = content.tagLinks()
            
            if let tagLinks {
                HStack(alignment: .center) {
                    ForEach(tagLinks) { link in
                        link
                            .padding([.trailing], 8)
                            .padding(.top, 4)
                    }
                }
                .class("d-flex", "flex-wrap")
                .margin(.top, -5)
            }
        }
    }
}


