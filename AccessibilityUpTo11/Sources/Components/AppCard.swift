import Foundation
import Ignite

// App card using shared site card structure and styling.
struct AppCard: HTML {
    let slug: String
    let title: String
    let subtitle: String
    let description: String
    let nameOrigin: String
    let imagePath: String
    let imageDescription: String
    let platforms: [String]
    let actions: [ActionItem]
    
    @MainActor var body: some HTML {
        Card {
            VStack(alignment: .leading) {
                Text(description)
                    .font(.body)
                    .padding(.bottom)
                
                Text(nameOrigin)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        } header: {
            VStack(alignment: .leading, spacing: 0) {
                Section {
                    BrandCopy.linkedInlineTitle(title, target: appURLPath(for: slug))
                        .font(.title3)
                        .foregroundStyle(.body)
                        .style(.overflowWrap, "break-word")
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .frame(width: .percent(100%))
                .background("var(--bs-secondary-bg)")
                .style(.borderBottom, "1px solid var(--bs-border-color)")

                HStack(alignment: .center, spacing: 16) {
                    LinkGroup(target: appURLPath(for: slug)) {
                        Image(imagePath, description: imageDescription)
                            .resizable()
                            .aspectRatio(.square, contentMode: .fit)
                            .frame(width: 96, height: 96)
                    }
                    .style(.flex, "0 0 auto")

                    VStack(alignment: .leading, spacing: 8) {
                        Text(subtitle)
                            .font(.body)
                            .foregroundStyle(.secondary)

                        if !platforms.isEmpty {
                            PlatformPillRow(platforms: platforms, appearance: .badge)
                        }
                    }
                    .style(.flex, "1 1 auto")
                    .style(.minWidth, "0")
                }
                .padding(16)
                .frame(width: .percent(100%))
                .background("var(--bs-card-bg)")
                .style(.borderBottom, "1px solid var(--bs-border-color)")
                .style(.flexWrap, "wrap")
            }
        } footer: {
            HStack(alignment: .center, spacing: 12) {
                ForEach(actions.filter { isAppStoreLink($0.target) }) { action in
                    AppStoreDownloadBadge(target: action.target)
                }

                ForEach(actions.filter { !isAppStoreLink($0.target) }) { action in
                    ActionButton(action: action)
                }
            }
            .style(.flexWrap, "wrap")
        }
        .class("app-card")
    }

    private func isAppStoreLink(_ target: String) -> Bool {
        target.contains("apps.apple.com")
    }
    
    private func appURLPath(for slug: String) -> String {
        "/apps/\(slug)"
    }
}
