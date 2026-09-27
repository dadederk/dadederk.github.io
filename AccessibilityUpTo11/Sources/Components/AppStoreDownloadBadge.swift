import Foundation
import Ignite

/// Official “Download on the App Store” badge from Apple Marketing Tools.
/// Artwork is used unmodified. The black badge is for light backgrounds and the
/// white badge is for dark backgrounds.
struct AppStoreDownloadBadge: HTML {
    let target: String

    @MainActor var body: some HTML {
        Link(target: target) {
            badgeImage(
                "/badges/download-on-the-app-store-black.svg",
                className: "app-store-badge-light"
            )
            badgeImage(
                "/badges/download-on-the-app-store-white.svg",
                className: "app-store-badge-dark"
            )
        }
        .textDecoration(.none)
        .style(.display, "flex")
        .style(.lineHeight, "0")
    }

    @MainActor private func badgeImage(_ path: String, className: String) -> some InlineElement {
        Image(path, description: "Download on the App Store")
            .frame(width: 120, height: 40)
            .class(className)
    }
}
