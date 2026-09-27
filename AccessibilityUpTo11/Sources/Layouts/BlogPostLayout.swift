import Foundation
import Ignite

struct BlogPostLayout: ArticlePage {
    @MainActor var body: some HTML {
        let meta = MetaBuilder.article(article)
        let structuredData = BlogPostingStructuredData.json(
            for: .init(
                headline: meta.title,
                description: meta.description,
                authorName: article.author ?? "Dani Devesa Derksen-Staats",
                authorURL: "\(SiteMeta.baseURL)/about",
                datePublished: article.date,
                dateModified: article.date,
                pageURL: SiteMeta.baseURL + article.path,
                keywords: article.tags?.joined(separator: ", ") ?? "",
                imagePath: meta.image,
                articleSection: "Technology"
            )
        )

        // Per-article meta is handled in MainLayout via MetaBuilder; JSON-LD remains here.
        Script(code: structuredData)
            .attribute("type", "application/ld+json")

        let articleFeaturedContent = BlogFeaturedContentLoader.featuredContent(for: article.path)
        let featuredSplit = FeaturedContentSplit.split(
            mentions: articleFeaturedContent?.mentions ?? [],
            quotes: articleFeaturedContent?.quotes ?? []
        )
        
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
                .padding(.bottom, 24)
            }

            if !featuredSplit.primary.isEmpty {
                Section {
                    FeaturedInBox(
                        title: articleFeaturedContent?.heading ?? "This post was featured in",
                        mentions: featuredSplit.primary.mentions,
                        quotes: featuredSplit.primary.quotes
                    )
                }
                .padding(.bottom, 24)
                .style(.width, "100%")
            }
            
            // Article content
            Section {
                Section {
                    article.text
                }
                .class("post-content")
                .horizontalAlignment(.leading)
            }
            .class("post-content-container")

            if !featuredSplit.additional.isEmpty {
                Section {
                    FeaturedInBox(
                        title: FeaturedContentSplit.additionalHeading,
                        mentions: featuredSplit.additional.mentions,
                        quotes: featuredSplit.additional.quotes
                    )
                }
                .padding(.top, 24)
                .style(.width, "100%")
            }

            Section {
                SupportWorkBox()
            }
            .padding(.top, 24)
            .style(.width, "100%")
            
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
                    "Content © Daniel Devesa Derksen-Staats on "
                    Link("Accessibility up to 11!", target: SiteMeta.baseURL)
                    " is licensed under "
                    Link("CC BY 4.0", target: SiteMeta.contentLicenseURL)
                    ". "
                    Link("License details", target: SiteMeta.contentLicensePath)
                }
                .font(.body)
                .foregroundStyle(.secondary)
                .horizontalAlignment(.leading)
            }
        }
        .horizontalAlignment(.leading)
    }

}
