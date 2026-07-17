import Foundation

/// BreadcrumbList JSON-LD for 365 Days post and tag routes.
enum BreadcrumbListStructuredData {
    struct Crumb {
        let name: String
        let url: String
    }

    static func json(crumbs: [Crumb]) -> String {
        struct StructuredData: Encodable {
            let context = "https://schema.org"
            let type = "BreadcrumbList"
            let itemListElement: [ListItem]

            struct ListItem: Encodable {
                let type = "ListItem"
                let position: Int
                let name: String
                let item: String

                enum CodingKeys: String, CodingKey {
                    case type = "@type"
                    case position, name, item
                }
            }

            enum CodingKeys: String, CodingKey {
                case context = "@context"
                case type = "@type"
                case itemListElement
            }
        }

        let items = crumbs.enumerated().map { index, crumb in
            StructuredData.ListItem(
                position: index + 1,
                name: crumb.name,
                item: crumb.url
            )
        }

        let data = StructuredData(itemListElement: items)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.withoutEscapingSlashes]
        guard let json = try? encoder.encode(data),
              let jsonString = String(data: json, encoding: .utf8)
        else {
            return ""
        }
        return jsonString
    }

    static func days365PostCrumbs(for post: Days365Data) -> [Crumb] {
        [
            .init(name: "Home", url: SiteMeta.baseURL + "/"),
            .init(name: "#365DaysIOSAccessibility", url: SiteMeta.baseURL + "/365-days-ios-accessibility"),
            .init(name: post.topicTitle, url: SiteMeta.baseURL + post.path),
        ]
    }

    static func days365TagCrumbs(tag: String, pagePath: String) -> [Crumb] {
        [
            .init(name: "Home", url: SiteMeta.baseURL + "/"),
            .init(name: "#365DaysIOSAccessibility", url: SiteMeta.baseURL + "/365-days-ios-accessibility"),
            .init(name: tag, url: SiteMeta.baseURL + pagePath),
        ]
    }
}
