import Foundation
import Ignite

struct BlogPostLayout: ArticlePage {
    @MainActor var body: some HTML {
        // Article-specific meta tags and structured data using Script element
        // This overrides the global meta tags for article pages with article-specific content
        Script(code: """
            // Remove global meta tags that should be overridden for articles
            const globalTagsToRemove = [
                'og:title', 'og:description', 'og:type', 'og:url', 'og:image',
                'twitter:title', 'twitter:description', 'twitter:image'
            ];
            
            globalTagsToRemove.forEach(property => {
                const existingTags = document.querySelectorAll(`meta[property="${property}"], meta[name="${property}"]`);
                existingTags.forEach(tag => tag.remove());
            });
            
            // Add article-specific Open Graph meta tags
            const articleMetaTags = [
                { property: 'og:title', content: '\(article.title.replacingOccurrences(of: "\"", with: "\\\""))' },
                { property: 'og:description', content: '\(article.description.replacingOccurrences(of: "\"", with: "\\\""))' },
                { property: 'og:type', content: 'article' },
                { property: 'og:url', content: 'https://accessibilityupto11.com\(article.path)' },
                { property: 'og:image', content: '\(article.image ?? "/Images/Site/Global/LogoShare.png")' },
                { property: 'article:author', content: '\(article.author ?? "Daniel Devesa Derksen-Staats")' },
                { property: 'article:published_time', content: '\(article.date.ISO8601Format())' },
                { property: 'article:section', content: 'Technology' }\(article.tags?.map { tag in
                    ",\n                { property: 'article:tag', content: '\(tag)' }"
                }.joined() ?? ""),
                { name: 'twitter:title', content: '\(article.title.replacingOccurrences(of: "\"", with: "\\\""))' },
                { name: 'twitter:description', content: '\(article.description.replacingOccurrences(of: "\"", with: "\\\""))' },
                { name: 'twitter:image', content: '\(article.image ?? "/Images/Site/Global/LogoShare.png")' }
            ];
            
            articleMetaTags.forEach(tag => {
                const meta = document.createElement('meta');
                if (tag.property) {
                    meta.setAttribute('property', tag.property);
                } else {
                    meta.setAttribute('name', tag.name);
                }
                meta.setAttribute('content', tag.content);
                document.head.appendChild(meta);
            });
            
            // Add JSON-LD structured data
            const structuredData = {
                "@context": "https://schema.org",
                "@type": "BlogPosting",
                "headline": "\(article.title.replacingOccurrences(of: "\"", with: "\\\""))",
                "description": "\(article.description.replacingOccurrences(of: "\"", with: "\\\""))",
                "author": {
                    "@type": "Person",
                    "name": "\(article.author ?? "Daniel Devesa Derksen-Staats")",
                    "url": "https://accessibilityupto11.com/about"
                },
                "publisher": {
                    "@type": "Organization",
                    "name": "Accessibility up to 11!",
                    "logo": {
                        "@type": "ImageObject",
                        "url": "https://accessibilityupto11.com/Images/Site/Global/LogoShare.png"
                    }
                },
                "datePublished": "\(article.date.ISO8601Format())",
                "dateModified": "\(article.date.ISO8601Format())",
                "mainEntityOfPage": {
                    "@type": "WebPage",
                    "@id": "https://accessibilityupto11.com\(article.path)"
                },
                "url": "https://accessibilityupto11.com\(article.path)",
                "articleSection": "Technology",
                "keywords": "\(article.tags?.joined(separator: ", ") ?? "")"
            };
            
            const script = document.createElement('script');
            script.type = 'application/ld+json';
            script.textContent = JSON.stringify(structuredData);
            document.head.appendChild(script);
            """)
        
        VStack(alignment: .leading) {
            // Article header with title and metadata
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    // Title
                    Text(article.title)
                        .font(.title1)
                        .fontWeight(.bold)
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
                Text(article.text)
                    .horizontalAlignment(.leading)
                    .padding(.horizontal)
            }
            
            // Article footer
            Section {
                Divider()
                    .padding(.vertical)
                
                Text("Published on \(article.date.formatted(date: .complete, time: .omitted))")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .horizontalAlignment(.center)
            }
            .padding(.horizontal)
        }
        .horizontalAlignment(.leading)
    }
}
