import Foundation
import Ignite

// Configurable action button with different styles
struct ActionButton: HTML {
    let title: String
    let target: String
    let style: ButtonStyle
    
    enum ButtonStyle {
        case primary
        case secondary
    }
    
    @MainActor var body: some HTML {
        Link(title, target: target)
            .class("btn", style == .primary ? "btn-primary" : "btn-secondary")
    }
}
