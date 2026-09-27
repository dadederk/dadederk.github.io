import Foundation
import Ignite

// Shared informational platform label used in app cards and app pages.
struct PlatformPill: HTML {
    enum Appearance {
        /// Bordered label used in app cards.
        case label
        /// Small capsule used beside an app name.
        case badge
    }

    let name: String
    var appearance: Appearance = .label

    init(_ name: String, appearance: Appearance = .label) {
        self.name = name
        self.appearance = appearance
    }

    @MainActor var body: some HTML {
        switch appearance {
        case .label:
            AnyHTML(
                Text(name)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 4)
                    .cornerRadius(4)
                    .style(.border, "1.5px solid var(--platform-pill-border)")
            )
        case .badge:
            AnyHTML(
                Text(name)
                    .font(.xSmall)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, .rem(0.6))
                    .padding(.vertical, .rem(0.12))
                    .cornerRadius(999)
                    .style(.display, "inline-block")
                    .style(.lineHeight, "1.3")
                    .style(.letterSpacing, "0.01em")
                    .style(.whiteSpace, "nowrap")
                    .style(.border, "1px solid var(--bs-border-color)")
                    .margin(.bottom, 0)
            )
        }
    }
}

// Shared row wrapper to keep platform-pill layout consistent.
struct PlatformPillRow: HTML {
    let platforms: [String]
    var appearance: PlatformPill.Appearance = .label

    @MainActor var body: some HTML {
        HStack(alignment: .bottom, spacing: appearance == .badge ? 6 : 4) {
            ForEach(platforms) { platform in
                PlatformPill(platform, appearance: appearance)
            }
        }
        .style(.flexWrap, "wrap")
    }
}
