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
        switch style {
        case .primary:
            Link(title, target: target)
                .linkStyle(.button)
                .role(.primary)
        case .secondary:
            Link(title, target: target)
                .linkStyle(.button)
                .role(.secondary)
        }
    }
}
