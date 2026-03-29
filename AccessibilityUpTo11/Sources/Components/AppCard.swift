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
    let actions: [ActionButton]
    
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
            VStack(alignment: .leading) {
                // App summary row replacing the previous image area.
                HStack(alignment: .center) {
                    LinkGroup(target: appURLPath(for: slug)) {
                        Image(imagePath, description: imageDescription)
                            .resizable()
                            .aspectRatio(.square, contentMode: .fit)
                            .frame(width: 96, height: 96)
                    }
                    
                    VStack(alignment: .leading) {
                        Text(subtitle)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .padding(.bottom, 5)
                        
                        if !platforms.isEmpty {
                            PlatformPillRow(platforms: platforms)
                        }
                    }
                    .style(.minWidth, "0")
                }
                .class("app-card-meta")
                .style(.flexWrap, "wrap")
                .style(.alignItems, "flex-start")

                Text {
                    Link(title, target: appURLPath(for: slug))
                }
                .font(.title3)
                .class("app-card-title")
                .class("text-break")
                .foregroundStyle(.body)
            }
        } footer: {
            HStack(alignment: .center) {
                ForEach(actions) { action in
                    action
                        .padding(.top, 4)
                }
            }
            .style(.display, "flex")
            .style(.flexWrap, "wrap")
            .margin(.top, -5)
        }
        .class("app-card")
    }
    
    private func appURLPath(for slug: String) -> String {
        "/apps/\(slug)"
    }
}
