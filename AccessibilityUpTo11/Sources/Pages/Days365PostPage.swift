import Foundation
import Ignite

struct Days365PostPage: StaticPage {
    let post: Days365Data
    
    var title: String { post.title }
    var path: String { post.path }
    
    @MainActor var body: some HTML {
        VStack {
            // SEO meta tags and structured data using Script element
            Script(code: """
                // Remove global meta tags that should be overridden for 365 days posts
                const globalTagsToRemove = [
                    'og:title', 'og:description', 'og:type', 'og:url', 'og:image',
                    'twitter:title', 'twitter:description', 'twitter:image'
                ];
                
                globalTagsToRemove.forEach(property => {
                    const existingTags = document.querySelectorAll(`meta[property="${property}"], meta[name="${property}"]`);
                    existingTags.forEach(tag => tag.remove());
                });
                
                // Add 365 days post-specific Open Graph meta tags
                const postMetaTags = [
                    { property: 'og:title', content: '\(post.title.replacingOccurrences(of: "\"", with: "\\\""))' },
                    { property: 'og:description', content: '\(post.excerpt.replacingOccurrences(of: "\"", with: "\\\""))' },
                    { property: 'og:type', content: 'article' },
                    { property: 'og:url', content: 'https://accessibilityupto11.com\(post.path)' },
                    { property: 'og:image', content: '\(post.image ?? "/Images/Site/Global/LogoShare.png")' },
                    { property: 'og:image:alt', content: '\(post.image != nil ? "\(post.title) - #365DaysIOSAccessibility" : "Accessibility up to 11! Logo")' },
                    { property: 'article:author', content: '\(post.author)' },
                    { property: 'article:published_time', content: '\(post.date.ISO8601Format())' },
                    { property: 'article:section', content: '#365DaysIOSAccessibility' },
                    { property: 'article:tag', content: '\(post.tags.joined(separator: ","))' },
                    { name: 'twitter:title', content: '\(post.title.replacingOccurrences(of: "\"", with: "\\\""))' },
                    { name: 'twitter:description', content: '\(post.excerpt.replacingOccurrences(of: "\"", with: "\\\""))' },
                    { name: 'twitter:image', content: '\(post.image ?? "/Images/Site/Global/LogoShare.png")' },
                    { name: 'twitter:image:alt', content: '\(post.image != nil ? "\(post.title) - #365DaysIOSAccessibility" : "Accessibility up to 11! Logo")' }
                ];
                
                postMetaTags.forEach(tag => {
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
                    "headline": "\(post.title.replacingOccurrences(of: "\"", with: "\\\""))",
                    "description": "\(post.excerpt.replacingOccurrences(of: "\"", with: "\\\""))",
                    "author": {
                        "@type": "Person",
                        "name": "\(post.author)",
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
                    "datePublished": "\(post.date.ISO8601Format())",
                    "dateModified": "\(post.date.ISO8601Format())",
                    "mainEntityOfPage": {
                        "@type": "WebPage",
                        "@id": "https://accessibilityupto11.com\(post.path)"
                    },
                    "url": "https://accessibilityupto11.com\(post.path)",
                    "articleSection": "#365DaysIOSAccessibility",
                    "keywords": "\(post.tags.joined(separator: ", "))",
                    "image": "\(post.image ?? "/Images/Site/Global/LogoShare.png")"
                };
                
                const script = document.createElement('script');
                script.type = 'application/ld+json';
                script.textContent = JSON.stringify(structuredData);
                document.head.appendChild(script);
            """)
            
            // Breadcrumb navigation
            Section {
                Link("#365DaysIOSAccessibility", target: "/365-days-ios-accessibility")
                    .foregroundStyle(.primary)
                    .font(.body)
                    .horizontalAlignment(.leading)
            }
            .horizontalAlignment(.leading)
            
            // Article header with title and metadata
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    // Title
                    Text(post.title)
                        .font(.title1)
                        .fontWeight(.bold)
                        .horizontalAlignment(.leading)
                    
                    // Date
                    Text(post.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .horizontalAlignment(.leading)
                    
                    // Tags (clickable)
                    if !post.tags.isEmpty {
                        HStack(spacing: 8) {
                            ForEach(post.tags) { tag in
                                Link(tag, target: "/365-days-ios-accessibility/tag/\(tag.lowercased().replacingOccurrences(of: " ", with: "-"))")
                                    .class("badge", "bg-primary", "text-white", "rounded-pill", "me-2")
                            }
                        }
                        .class("flex-wrap")
                        .horizontalAlignment(.leading)
                    }
                    
                    // Article metadata
                    if !post.author.isEmpty {
                        HStack {
                            Text("By ")
                                .font(.body)
                                .foregroundStyle(.secondary)
                            
                            Link(post.author, target: "/about")
                                .font(.body)
                                .foregroundStyle(.primary)
                        }
                        .horizontalAlignment(.leading)
                    }
                }
                .horizontalAlignment(.leading)
            }
            .padding(.vertical, 24)
            
            // Article content
            Section {
                MarkdownRenderer(content: post.content)
                    .horizontalAlignment(.leading)
                    .padding(.horizontal)
            }
            
            // Navigation to other posts
            Section {
                let allPosts = Days365Loader.loadPosts()
                let currentIndex = allPosts.firstIndex(where: { $0.fileName == post.fileName }) ?? 0
                
                Divider()
                    .padding(.top)
                
                HStack {
                    // Previous post (newer)
                    if currentIndex > 0 {
                        let previousPost = allPosts[currentIndex - 1]
                        Link("← Day \(previousPost.dayNumber)", target: previousPost.path)
                            .class("btn", "btn-outline-secondary")
                    } else {
                        Spacer()
                    }
                    
                    Spacer()
                    
                    // Next post (older)
                    if currentIndex < allPosts.count - 1 {
                        let nextPost = allPosts[currentIndex + 1]
                        Link("Day \(nextPost.dayNumber) →", target: nextPost.path)
                            .class("btn", "btn-outline-secondary")
                    }
                }
            }
            .padding(.bottom)
        }
        .horizontalAlignment(.leading)
    }
}
