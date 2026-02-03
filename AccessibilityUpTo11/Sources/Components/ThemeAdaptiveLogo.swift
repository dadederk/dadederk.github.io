import Foundation
import Ignite

/// Shows the correct logo for light/dark mode using Ignite's ~dark asset variant.
struct ThemeAdaptiveLogo: InlineElement {
    var size: Int = 64
    var description: String = "Accessibility up to 11! Logo"
    
    @MainActor var body: some InlineElement {
        Image("/Images/Site/Global/Logo.png", description: description)
            .resizable()
            .frame(width: .px(size), height: .px(size))
    }
}
