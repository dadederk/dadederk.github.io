import Foundation
import Ignite

struct Blog: StaticPage {
    var title = "Blog"
    var path = "/blog"
    
    @Environment(\.articles) var articles
    
    var body: some HTML {
        VStack {
            // Blog posts list - single column, chronological using custom ArticlePreview components
            Section {
                let allArticles = articles.all.sorted(by: \.date, order: .reverse)
                
                if !allArticles.isEmpty {
                    VStack(spacing: 6) {
                        ForEach(allArticles) { article in
                            ArticlePreview(for: article)
                                .articlePreviewStyle(BlogArticlePreviewStyle())
                        }
                    }
                    .padding(.bottom, 2)
                } else {
                    Text("No blog posts available yet.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .padding(.vertical)
                }
            }
        }
    }
}

// Custom article preview style for Blog page with horizontal layout
@MainActor
struct BlogArticlePreviewStyle: @MainActor ArticlePreviewStyle {
    func body(content: Article) -> any HTML {
        Card {
            // Content area - responsive layout
            Group {
                // Desktop/tablet layout (horizontal)
                HStack(alignment: .top) {
                    // Image on the left (only if image exists)
                    VStack(alignment: .center) {
                        if let image = content.image {
                            Image(image, description: content.imageDescription)
                                .resizable()
                                .frame(maxWidth: 200, maxHeight: 150)
                                .cornerRadius(8)
                                .padding(.trailing)
                        }
                    }
                    
                    // Text content on the right
                    VStack(alignment: .leading) {
                        Text(content.description)
                            .font(.body)
                            .padding(.bottom)
                        
                        // Article metadata
                        HStack {
                            if let author = content.author {
                                Text("By \(author)")
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                                    .fontWeight(.semibold)
                            }
                            
                            Spacer()
                            
                            Text(content.date.formatted(date: .abbreviated, time: .omitted))
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .fontWeight(.semibold)
                        }
                        
                        Text("\(content.estimatedReadingMinutes) minutes to read")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .fontWeight(.semibold)
                    }
                }
                .class("d-none", "d-md-flex") // Hide on mobile, show on md and up
                
                // Mobile layout (vertical - same as Home page)
                VStack(alignment: .leading) {
                    // Image on top for mobile
                    if let image = content.image {
                        Image(image, description: content.imageDescription)
                            .resizable()
                            .frame(maxWidth: 300, maxHeight: 200)
                            .cornerRadius(8)
                            .padding(.bottom)
                    }
                    
                    Text(content.description)
                        .font(.body)
                        .padding(.bottom)
                    
                    HStack {
                        if let author = content.author {
                            Text("By \(author)")
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .fontWeight(.semibold)
                        }
                        
                        Spacer()
                        
                        Text(content.date.formatted(date: .abbreviated, time: .omitted))
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .fontWeight(.semibold)
                    }
                    
                    Text("\(content.estimatedReadingMinutes) minutes to read")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .fontWeight(.semibold)
                }
                .class("d-md-none") // Show only on mobile
            }
            .margin(.bottom, .none)
            .padding(.bottom, .none)
        } header: {
            // Title in the header (with background and separator)
            Text {
                Link(content)
            }
            .font(.title2)
        } footer: {
            // Tags in the footer (with background and separator)
            if let tagLinks = content.tagLinks() {
                Section {
                    ForEach(tagLinks) { link in
                        link
                            .padding([.trailing])
                    }
                }
                .margin(.top, -5)
            }
        }
    }
}
