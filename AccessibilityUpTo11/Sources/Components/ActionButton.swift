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

extension ActionButton {
    init(action: ActionItem) {
        self.init(
            title: action.title,
            target: action.target,
            style: action.style == "primary" ? .primary : .secondary
        )
    }
}

/// Outline control matching Terms, Privacy, and Support on an app page.
struct PillLink: HTML {
    let title: String
    let target: String

    @MainActor var body: some HTML {
        Link(title, target: target)
            .padding(.vertical, .small)
            .padding(.horizontal)
            .cornerRadius(8)
            .textDecoration(.none)
            .background("transparent")
            .foregroundStyle("var(--bs-primary)")
            // Inline links let vertical padding paint outside the line box, so
            // stacked pills overlap the row gap.
            .style(.display, "inline-block")
            // Ignite's border modifier only accepts a Color, which always emits rgb().
            .style(.border, "1px solid var(--bs-primary)")
    }
}
