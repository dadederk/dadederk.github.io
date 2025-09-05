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
        }
        .navigationItemAlignment(.trailing)
        .style(.backgroundColor, "var(--bs-navbar-bg)")
        .ignorePageGutters()
        .position(.fixedTop)
        .border(.darkGray, edges: [.bottom])
    }
}
