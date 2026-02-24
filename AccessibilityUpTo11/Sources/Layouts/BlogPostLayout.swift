import Foundation
import Ignite

struct BlogPostLayout: ArticlePage {
    @MainActor var body: some HTML {
        let meta = MetaBuilder.article(article)
        
        let structuredData: String = {
            struct StructuredData: Encodable {
                let context = "https://schema.org"
                let type = "BlogPosting"
                let headline: String
                let description: String
                let author: Author
                let publisher: Publisher
                let datePublished: String
                let dateModified: String
                let mainEntityOfPage: MainEntity
                let url: String
                let articleSection: String
                let keywords: String
                let image: String
                
                struct Author: Encodable {
                    let type = "Person"
                    let name: String
                    let url: String
                    
                    enum CodingKeys: String, CodingKey {
                        case type = "@type"
                        case name, url
                    }
                }
                
                struct Publisher: Encodable {
                    let type = "Organization"
                    let name: String
                    let logo: Logo
                    
                    struct Logo: Encodable {
                        let type = "ImageObject"
                        let url: String
                        
                        enum CodingKeys: String, CodingKey {
                            case type = "@type"
                            case url
                        }
                    }
                    
                    enum CodingKeys: String, CodingKey {
                        case type = "@type"
                        case name, logo
                    }
                }
                
                struct MainEntity: Encodable {
                    let type = "WebPage"
                    let id: String
                    
                    enum CodingKeys: String, CodingKey {
                        case type = "@type"
                        case id = "@id"
                    }
                }
                
                enum CodingKeys: String, CodingKey {
                    case context = "@context"
                    case type = "@type"
                    case headline, description, author, publisher, datePublished, dateModified, mainEntityOfPage, url, articleSection, keywords, image
                }
            }
            
            let data = StructuredData(
                headline: meta.title,
                description: meta.description,
                author: .init(name: article.author ?? "Daniel Devesa Derksen-Staats", url: "\(SiteMeta.baseURL)/about"),
                publisher: .init(name: "Accessibility up to 11!", logo: .init(url: SiteMeta.baseURL + SiteMeta.defaultImage)),
                datePublished: article.date.ISO8601Format(),
                dateModified: article.date.ISO8601Format(),
                mainEntityOfPage: .init(id: SiteMeta.baseURL + article.path),
                url: SiteMeta.baseURL + article.path,
                articleSection: "Technology",
                keywords: article.tags?.joined(separator: ", ") ?? "",
                image: SiteMeta.baseURL + meta.image
            )
            
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.withoutEscapingSlashes]
            if let json = try? encoder.encode(data), let jsonString = String(data: json, encoding: .utf8) {
                return jsonString
            }
            return ""
        }()
        
        // Per-article meta is handled in MainLayout via MetaBuilder; JSON-LD remains here.
        Script(code: structuredData)
            .attribute("type", "application/ld+json")
        
        VStack(alignment: .leading) {
            // Article header with title and metadata
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    // Title
                    Text(article.title)
                        .font(.title1)
                        .fontWeight(.bold)
                        .class("text-break")
                        .horizontalAlignment(.leading)
                    
                    // Date (moved under title)
                    Text(article.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .horizontalAlignment(.leading)
                    
                    // Tags (now clickable using built-in tagLinks)
                    if let tagLinks = article.tagLinks() {
                        HStack(spacing: 8) {
                            ForEach(tagLinks) { link in
                                link
                            }
                        }
                        .style(.flexWrap, "wrap")
                        .horizontalAlignment(.leading)
                    }
                    
                    // Article metadata
                    VStack(alignment: .leading, spacing: 6) {
                        if let author = article.author {
                            Text("By \(author)")
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .horizontalAlignment(.leading)
                        }
                        
                        if article.estimatedWordCount > 0 {
                            Text("\(article.estimatedWordCount) words; \(article.estimatedReadingMinutes) minutes to read")
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .horizontalAlignment(.leading)
                        }
                    }
                }
                .horizontalAlignment(.leading)
                .padding(.horizontal)
                .padding(.vertical, 24)
            }
            
            // Article content
            Section {
                Section {
                    article.text
                }
                .class("post-content")
                .horizontalAlignment(.leading)
                .padding(.horizontal)
            }
            .class("post-content-container")
            
            // Related articles section
            @Environment(\.articles) var articles
            let relatedArticles = Article.relatedArticles(for: article, from: articles.all)
            RelatedArticlesSection(relatedArticles: relatedArticles)
            
            // Article footer
            Section {
                Divider()
                    .padding(.vertical)
                
                Text("Published on \(article.date.formatted(date: .complete, time: .omitted))")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .horizontalAlignment(.leading)

                Text {
                    "Content © Daniel Devesa Derksen-Staats — "
                    Link("Accessibility up to 11!", target: "https://accessibilityupto11.com")
                }
                .font(.body)
                .foregroundStyle(.secondary)
                .horizontalAlignment(.leading)
            }
            .padding(.horizontal)
        }
        .horizontalAlignment(.leading)
    }
}
