import Foundation

/// Shared BlogPosting JSON-LD encoder for blog and 365 Days articles.
enum BlogPostingStructuredData {
    struct Input {
        let headline: String
        let description: String
        let authorName: String
        let authorURL: String
        let datePublished: Date
        let dateModified: Date
        let pageURL: String
        let keywords: String
        let imagePath: String
        let articleSection: String
    }

    static func json(for input: Input) -> String {
        struct StructuredData: Encodable {
            let context = "https://schema.org"
            let type = "BlogPosting"
            let headline: String
            let description: String
            let author: Author
            let publisher: Publisher
            let datePublished: String
            let dateModified: String
            let mainEntityOfPage: MainEntity
            let url: String
            let articleSection: String
            let keywords: String
            let image: String

            struct Author: Encodable {
                let type = "Person"
                let name: String
                let url: String

                enum CodingKeys: String, CodingKey {
                    case type = "@type"
                    case name, url
                }
            }

            struct Publisher: Encodable {
                let type = "Organization"
                let name: String
                let logo: Logo

                struct Logo: Encodable {
                    let type = "ImageObject"
                    let url: String

                    enum CodingKeys: String, CodingKey {
                        case type = "@type"
                        case url
                    }
                }

                enum CodingKeys: String, CodingKey {
                    case type = "@type"
                    case name, logo
                }
            }

            struct MainEntity: Encodable {
                let type = "WebPage"
                let id: String

                enum CodingKeys: String, CodingKey {
                    case type = "@type"
                    case id = "@id"
                }
            }

            enum CodingKeys: String, CodingKey {
                case context = "@context"
                case type = "@type"
                case headline, description, author, publisher, datePublished, dateModified, mainEntityOfPage, url, articleSection, keywords, image
            }
        }

        let data = StructuredData(
            headline: input.headline,
            description: input.description,
            author: .init(name: input.authorName, url: input.authorURL),
            publisher: .init(
                name: "Accessibility up to 11!",
                logo: .init(url: SiteMeta.baseURL + SiteMeta.defaultImage)
            ),
            datePublished: input.datePublished.ISO8601Format(),
            dateModified: input.dateModified.ISO8601Format(),
            mainEntityOfPage: .init(id: input.pageURL),
            url: input.pageURL,
            articleSection: input.articleSection,
            keywords: input.keywords,
            image: SiteMeta.absoluteImageURL(for: input.imagePath)
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.withoutEscapingSlashes]
        guard let json = try? encoder.encode(data),
              let jsonString = String(data: json, encoding: .utf8)
        else {
            return ""
        }
        return jsonString
    }
}
