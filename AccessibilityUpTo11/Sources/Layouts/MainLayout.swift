import Foundation
import Ignite

struct MainLayout: Layout {
    @Environment(\.page) var page
    
    @MainActor var body: some Document {
        PlainDocument {
            Head {
                // Essential meta tags for SEO and functionality
                MetaTag(name: "viewport", content: "width=device-width, initial-scale=1")
                MetaTag(name: "description", content: "iOS accessibility development blog and resources for developers who want to make their apps accessible to everyone.")
                MetaTag(name: "author", content: "Daniel Devesa Derksen-Staats")
                MetaTag(name: "keywords", content: "iOS, accessibility, a11y, Swift, VoiceOver, development")
                
                // Enhanced meta tags for better SEO and social sharing
                MetaTag(name: "robots", content: "index, follow, max-snippet:-1, max-image-preview:large")
                MetaTag(name: "googlebot", content: "index, follow")
                
                // Global Open Graph meta tags for SEO and social sharing
                MetaTag(property: "og:title", content: "Accessibility up to 11!")
                MetaTag(property: "og:description", content: "iOS accessibility development blog and resources for developers who want to make their apps accessible to everyone.")
                MetaTag(property: "og:type", content: "website")
                MetaTag(property: "og:url", content: "https://accessibilityupto11.com")
                MetaTag(property: "og:image", content: "https://accessibilityupto11.com/Images/Site/Global/Logo.png")
                MetaTag(property: "og:image:alt", content: "Accessibility up to 11! Logo")
                MetaTag(property: "og:site_name", content: "Accessibility up to 11!")
                MetaTag(property: "og:locale", content: "en_US")
                
                // Global Twitter Card meta tags
                MetaTag(name: "twitter:card", content: "summary_large_image")
                MetaTag(name: "twitter:title", content: "Accessibility up to 11!")
                MetaTag(name: "twitter:description", content: "iOS accessibility development blog and resources for developers who want to make their apps accessible to everyone.")
                MetaTag(name: "twitter:image", content: "https://accessibilityupto11.com/Images/Site/Global/Logo.png")
                MetaTag(name: "twitter:image:alt", content: "Accessibility up to 11! Logo")
                MetaTag(name: "twitter:site", content: "@dadederk")
                MetaTag(name: "twitter:creator", content: "@dadederk")
                
                // Custom CSS for navigation and theme support
                MetaLink(href: "/custom-navigation.css", rel: "stylesheet")

                // Set theme data attributes for Ignite's theme switching JavaScript
                Script(code: """
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
                    """)
            }
            
            Body {
                // Header - Custom LogoNavBar component
                LogoNavBar()
                
                // Main content area
                Section {
                    content
                }
                .id("main-content")
                .padding()

                
                // Footer - Ignite component, much shorter
                IgniteFooter()
                    .position(.stickyBottom)
                    .style(.backgroundColor, "var(--bs-secondary-bg)")
                    .border(.gray, edges: .top)
                    .ignorePageGutters()
            }
            .data("current-page", page.url.path)
        }
    }
}