import Foundation
import Ignite

struct MainLayout: Layout {
    @Environment(\.page) var page
    
    @MainActor var body: some Document {
        let meta = Self.metaContext(title: page.title, path: page.url.path)
        
        PlainDocument {
            Head {
                MetaTag(name: "keywords", content: "iOS, accessibility, a11y, Swift, VoiceOver, development")
                MetaTag(name: "robots", content: "index, follow, max-snippet:-1, max-image-preview:large")
                MetaTag(name: "googlebot", content: "index, follow")
                
                MetaLink(href: meta.absoluteURL, rel: "canonical")
                
                MetaTag(property: "og:type", content: meta.type.rawValue)
                MetaTag(property: "og:title", content: meta.title)
                MetaTag(property: "og:description", content: meta.description)
                MetaTag(property: "og:url", content: meta.absoluteURL)
                MetaTag(property: "og:image", content: SiteMeta.baseURL + meta.image)
                MetaTag(property: "og:image:alt", content: meta.imageAlt)
                MetaTag(property: "og:locale", content: "en_US")
                
                MetaTag(name: "twitter:card", content: meta.twitterCard)
                MetaTag(name: "twitter:title", content: meta.title)
                MetaTag(name: "twitter:description", content: meta.description)
                MetaTag(name: "twitter:image", content: SiteMeta.baseURL + meta.image)
                MetaTag(name: "twitter:image:alt", content: meta.imageAlt)
                MetaTag(name: "twitter:site", content: "@dadederk")
                MetaTag(name: "twitter:creator", content: "@dadederk")
                
                MetaLink(href: "/custom-navigation.css", rel: "stylesheet")
                MetaLink(href: "/Images/Site/Global/a11yupto11favicon.png", rel: "icon")
                MetaLink(href: "/Images/Site/Global/a11yupto11favicon.png", rel: "apple-touch-icon")

                Script(code: """
                (function() {
                    const root = document.documentElement;
                    root.setAttribute('data-light-theme', 'accessibility-up-to11-light');
                    root.setAttribute('data-dark-theme', 'accessibility-up-to11-dark-dark');

                    const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
                    const lightThemeID = root.getAttribute('data-light-theme') || 'light';
                    const darkThemeID = root.getAttribute('data-dark-theme') || 'dark';
                    const savedTheme = localStorage.getItem('custom-theme')
                        || root.getAttribute('data-theme-state')
                        || 'auto';
                    const actualThemeID = savedTheme === 'auto'
                        ? (prefersDark ? darkThemeID : lightThemeID)
                        : savedTheme;

                    root.setAttribute('data-bs-theme', actualThemeID);
                    if (!root.getAttribute('data-theme-state')) {
                        root.setAttribute('data-theme-state', savedTheme);
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
    @MainActor static func metaContext(title: String, path: String) -> MetaContext {
        
        // 365 Days individual post
        if path.hasPrefix("/365-days-ios-accessibility/") {
            let slug = path.replacingOccurrences(of: "/365-days-ios-accessibility/", with: "")
            if let post = Days365Loader.post(withFileName: slug) {
                return MetaBuilder.days365(post)
            }
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
        
        return MetaBuilder.siteFallback(title: title, path: path)
    }
}
