import Foundation
import Ignite

struct LogoNavBar: HTML {
    @MainActor var body: some HTML {
        NavigationBar {
            Link("Blog", target: "/blog")
            Link("Apps", target: "/apps")
            Dropdown("More Content") {
                Link("Publications", target: "/more-content#publications")
                Link("Talks", target: "/more-content#talks")
                Link("Podcasts", target: "/more-content#podcasts")
            }
            Link("About", target: "/about")
            Link("RSS", target: "/feed.rss")
        } logo: {
            // Custom logo with image and text using Span for text
            // Light mode logo
            Image("/Images/Site/Global/Logo.png", description: "Accessibility up to 11! Logo")
                .resizable()
                .frame(width: 64, height: 64)
                .class("logo-light")
            
            // Dark mode logo
            Image("/Images/Site/Global/LogoDarkMode.png", description: "Accessibility up to 11! Logo - Dark Mode")
                .resizable()
                .frame(width: 64, height: 64)
                .class("logo-dark")
            
            Span("Accessibility up to 11!")
                .font(.title1)
                .fontWeight(.bold)
                .class("d-none d-lg-block") // Show on large screens (desktop)
                .attribute("aria-label", "Accessibility up to 11!")

            Span("Accessibility up to 11!")
                .font(.title6)
                .fontWeight(.bold)
                .class("d-lg-none") // Show on small/medium screens (mobile/tablet)
                .attribute("aria-label", "Accessibility up to 11!")
        }
        .navigationItemAlignment(.trailing)
        .style(.backgroundColor, "var(--bs-navbar-bg)")
        .ignorePageGutters()
        .position(.fixedTop)
        .border(.darkGray, edges: [.bottom])
    }
}
