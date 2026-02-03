import Foundation
import Ignite

struct LogoNavBar: HTML {
    @Environment(\.page) var page
    
    @MainActor var body: some HTML {
        NavigationBar {
            navLink("Blog", path: "/blog")
            navLink("#365DaysIOSAccessibility", path: "/365-days-ios-accessibility")
            navLink("Apps", path: "/apps")
            navLink("About", path: "/about")
            navLink("Resources", path: "/resources")
            Link("RSS", target: "/feed.rss")
        } logo: {
            ThemeAdaptiveLogo()
            Span("Accessibility up to 11!")
                .font(.title5)
                .fontWeight(.bold)
                .attribute("aria-label", "Accessibility up to 11!")
        }
        .navigationItemAlignment(.trailing)
        .position(.fixedTop)
        .padding(.horizontal)
        .style(.backgroundColor, "var(--bs-secondary-bg)")
        .style(.zIndex, "1000")
        .border(.darkGray, edges: [.bottom])
        .ignorePageGutters()
    }
    
    @MainActor private func navLink(_ title: String, path: String) -> Link {
        Link(title, target: path)
    }
}
