import Foundation
import Ignite

// Shared informational platform label used in app cards and app pages.
struct PlatformPill: HTML {
    let name: String

    init(_ name: String) {
        self.name = name
    }

    @MainActor var body: some HTML {
        Text(name)
            .font(.body)
            .fontWeight(.medium)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 4)
            .padding(.vertical, 4)
            .class("platform-pill")
            .cornerRadius(4)
    }
}

// Shared row wrapper to keep platform-pill layout consistent.
struct PlatformPillRow: HTML {
    let platforms: [String]

    @MainActor var body: some HTML {
        HStack(spacing: 4) {
            ForEach(platforms) { platform in
                PlatformPill(platform)
            }
        }
        .style(.flexWrap, "wrap")
    }
}
