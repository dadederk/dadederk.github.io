import Foundation
import Ignite

/// Shows the correct logo for light/dark mode using CSS theme classes.
struct ThemeAdaptiveLogo: InlineElement {
    var size: Int = 64
    var description: String = "Accessibility up to 11! Logo"

    @MainActor var body: some InlineElement {
        InlineGroup {
            Image("/Images/Site/Global/Logo.png", description: description)
                .resizable()
                .frame(width: .px(size), height: .px(size))
                .class("logo-light", "site-logo")

            Image("/Images/Site/Global/Logo~dark.png", description: "\(description) - Dark Mode")
                .resizable()
                .frame(width: .px(size), height: .px(size))
                .class("logo-dark", "site-logo")
        }
    }
}
