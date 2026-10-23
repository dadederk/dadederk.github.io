import Foundation

enum SoftwareApplicationStructuredData {
    static func json(for app: AppItem) -> String {
        struct Reference: Encodable {
            let id: String

            enum CodingKeys: String, CodingKey {
                case id = "@id"
            }
        }

        struct StructuredData: Encodable {
            let context = "https://schema.org"
            let type = "SoftwareApplication"
            let name: String
            let description: String
            let url: String
            let image: String
            let operatingSystem: String
            let applicationCategory: String
            let downloadUrl: String?
            let author: Reference

            enum CodingKeys: String, CodingKey {
                case context = "@context"
                case type = "@type"
                case name, description, url, image, operatingSystem
                case applicationCategory, downloadUrl, author
            }
        }

        let category: String
        switch app.category {
        case .game:
            category = "GameApplication"
        case .app, .stickerPack:
            category = "UtilitiesApplication"
        }

        let data = StructuredData(
            name: app.title,
            description: app.description,
            url: SiteMeta.absolutePageURL(for: "/apps/\(app.slug)"),
            image: SiteMeta.absoluteImageURL(for: app.imagePath),
            operatingSystem: app.platforms.joined(separator: ", "),
            applicationCategory: category,
            downloadUrl: app.actions.first { $0.target.contains("apps.apple.com") }?.target,
            author: .init(id: SiteMeta.authorID)
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.withoutEscapingSlashes]
        guard let encoded = try? encoder.encode(data),
              let output = String(data: encoded, encoding: .utf8)
        else {
            return ""
        }
        return output
    }
}
