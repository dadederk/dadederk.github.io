import Foundation
import Ignite

struct MainLayout: Layout {
    @Environment(\.page) var page
    
    @MainActor var body: some Document {
        let meta = metaContext()
        let assetVersion = "2026-02-24"
        
        PlainDocument {
            Head {
                MetaTag(name: "keywords", content: "iOS, accessibility, a11y, Swift, VoiceOver, development")
                MetaTag(name: "robots", content: "index, follow, max-snippet:-1, max-image-preview:large")
                MetaTag(name: "googlebot", content: "index, follow")

                // og:type and og:locale are not injected by Ignite's socialSharingTags().
                MetaTag(property: "og:type", content: meta.type.rawValue)
                MetaTag(property: "og:locale", content: "en_US")

                // Ignite is the primary source for image tags.
                // We only inject image tags for routes that need fallback/absolute safety.
                if meta.emitCustomImageTags {
                    MetaTag(property: "og:image", content: meta.imageURL)
                    MetaTag(name: "twitter:image", content: meta.imageURL)
                }
                MetaTag(property: "og:image:alt", content: meta.imageAlt)
                
                MetaTag(name: "twitter:image:alt", content: meta.imageAlt)

                // Ignite injects description tags only when page.description is non-empty.
                if meta.emitCustomDescriptionTags {
                    MetaTag(property: "og:description", content: meta.description)
                    MetaTag(name: "twitter:description", content: meta.description)
                }

                MetaTag(name: "twitter:site", content: "@dadederk")
                MetaTag(name: "twitter:creator", content: "@dadederk")
                
                MetaLink(href: "/css/ignite-core.min.css?v=\(assetVersion)", rel: "stylesheet")
                MetaLink(href: "/custom-navigation.css?v=\(assetVersion)", rel: "stylesheet")
                MetaLink(href: "/Images/Site/Global/a11yupto11favicon.png", rel: "icon")
                MetaLink(href: "/Images/Site/Global/a11yupto11favicon.png", rel: "apple-touch-icon")

                Script(code: """
                (function() {
                    // Set theme data attributes immediately
                    document.documentElement.setAttribute('data-light-theme', 'accessibility-up-to11-light');
                    document.documentElement.setAttribute('data-dark-theme', 'accessibility-up-to11-dark-dark');

                    // Apply theme immediately based on system preference
                    const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
                    const themeID = prefersDark ? 'accessibility-up-to11-dark-dark' : 'accessibility-up-to11-light';
                    document.documentElement.setAttribute('data-bs-theme', themeID);

                    // Apply syntax highlighting theme immediately
                    const syntaxTheme = getComputedStyle(document.documentElement)
                        .getPropertyValue('--syntax-highlight-theme').trim().replace(/"/g, '');
                    if (syntaxTheme) {
                        document.querySelectorAll('link[data-highlight-theme]').forEach(link => {
                            link.setAttribute('disabled', 'disabled');
                        });
                        const themeLink = document.querySelector(`link[data-highlight-theme="${syntaxTheme}"]`);
                        if (themeLink) {
                            themeLink.removeAttribute('disabled');
                        }
                    }
                })();
                """)
            }
            
            Body {
                LogoNavBar()
                
                // Main content area
                Section {
                    content
                }
                .id("main-content")
                .padding()
                .padding(.top, 80)
                .padding(.bottom, 80)
                
                // Footer - Fixed bottom implementation
                Section {
                    HStack(alignment: .center) {
                        Text {
                            "Created in Swift with "
                            Link("Ignite.", target: "https://github.com/twostraws/Ignite")
                        }
                        
                        Link(target: "https://swiftforswifts.org") {
                            Image(decorative: "https://swiftforswifts.org/downloads/swift-for-swifts-icon.png")
                                .resizable()
                                .frame(height: .em(2.0))
                        }
                        
                        Link("Supporting Swift for Swifts", target: "https://swiftforswifts.org/")
                            .target(.newWindow)
                            .relationship(.noOpener)
                    }
                    .style(.justifyContent, "center")
                    .style(.width, "100%")
                }
                .position(.fixedBottom)
                .padding(.vertical)
                .horizontalAlignment(.center)
                .style(.backgroundColor, "var(--bs-secondary-bg)")
                .style(.zIndex, "900")
                .border(.gray, edges: .top)
                .ignorePageGutters()
            }
            .data("current-page", page.url.path)
        }
    }
}

extension MainLayout {
    @MainActor func metaContext() -> MetaContext {
        let path = page.url.path
        let title = page.title
        let defaultType: MetaContext.ContentType = path.hasPrefix("/post/") ? .article : .website

        // 365 Days individual post
        if path.hasPrefix("/365-days-ios-accessibility/") {
            let slug = path.replacingOccurrences(of: "/365-days-ios-accessibility/", with: "")
            if let post = Days365Loader.post(withFileName: slug) {
                return MetaBuilder.days365(post)
            }
        }

        // Blog post — Ignite populates page.image with the article's image path
        // (often relative), so we emit custom image tags for absolute URL safety.
        if path.hasPrefix("/post/") {
            return MetaBuilder.page(
                title: title,
                description: page.description,
                path: path,
                image: page.image?.absoluteString,
                imageAlt: title,
                type: .article,
                emitCustomImageTags: true,
                emitCustomDescriptionTags: page.description.isEmpty
            )
        }
        
        // App pages
        if path.hasPrefix("/apps/") {
            let remainder = path.replacingOccurrences(of: "/apps/", with: "")
            let components = remainder.split(separator: "/", omittingEmptySubsequences: true)
            if let identifier = components.first {
                let type: UniversalAppPage.AppPageType
                if components.count > 1 {
                    switch components[1] {
                    case "terms": type = .terms
                    case "privacy": type = .privacy
                    default: type = .main
                    }
                } else {
                    type = .main
                }
                
                let appsData = AppsData.loadContent()
                if let app = appsData.apps.first(where: { $0.slug.lowercased() == identifier.lowercased() }) {
                    return MetaBuilder.app(app, pageType: type)
                }
            }
        }

        // Ignite's TagPage type does not expose per-page image metadata.
        if path == "/tags" || path.hasPrefix("/tags/") {
            return MetaBuilder.page(
                title: title,
                description: page.description,
                path: path,
                image: page.image?.absoluteString,
                imageAlt: title,
                type: .website,
                emitCustomImageTags: true,
                emitCustomDescriptionTags: page.description.isEmpty
            )
        }
        
        return MetaBuilder.page(
            title: title,
            description: page.description,
            path: path,
            image: page.image?.absoluteString,
            imageAlt: title,
            type: defaultType,
            emitCustomImageTags: page.image == nil,
            emitCustomDescriptionTags: page.description.isEmpty
        )
    }
}
