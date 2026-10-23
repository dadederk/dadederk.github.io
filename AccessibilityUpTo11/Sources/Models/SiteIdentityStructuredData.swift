import Foundation

/// A stable entity graph that helps search engines and answer engines connect
/// the site, its publisher, and the author across pages.
enum SiteIdentityStructuredData {
    static func json() -> String {
        struct Graph: Encodable {
            let context = "https://schema.org"
            let graph: [Entity]

            enum CodingKeys: String, CodingKey {
                case context = "@context"
                case graph = "@graph"
            }
        }

        struct Entity: Encodable {
            let id: String
            let type: String
            let name: String
            let alternateName: String?
            let url: String
            let description: String?
            let inLanguage: String?
            let jobTitle: String?
            let sameAs: [String]?
            let logo: Reference?
            let founder: Reference?
            let publisher: Reference?
            let author: Reference?

            enum CodingKeys: String, CodingKey {
                case id = "@id"
                case type = "@type"
                case name, alternateName, url, description, inLanguage, jobTitle
                case sameAs, logo, founder, publisher, author
            }
        }

        struct Reference: Encodable {
            let id: String

            enum CodingKeys: String, CodingKey {
                case id = "@id"
            }
        }

        let author = Entity(
            id: SiteMeta.authorID,
            type: "Person",
            name: "Daniel Devesa Derksen-Staats",
            alternateName: "Dani Devesa Derksen-Staats",
            url: SiteMeta.authorPageURL,
            description: "iOS engineer and accessibility specialist focused on inclusive Apple-platform development.",
            inLanguage: nil,
            jobTitle: "iOS Engineer and Accessibility Specialist",
            sameAs: [
                "https://twitter.com/dadederk",
                "https://iosdev.space/@dadederk",
                "https://bsky.app/profile/dadederk.bsky.social",
                "https://www.linkedin.com/in/danieldevesa/",
                "https://github.com/dadederk",
            ],
            logo: nil,
            founder: nil,
            publisher: nil,
            author: nil
        )

        let organization = Entity(
            id: SiteMeta.organizationID,
            type: "Organization",
            name: "Accessibility up to 11!",
            alternateName: nil,
            url: SiteMeta.baseURL + "/",
            description: SiteMeta.defaultDescription,
            inLanguage: nil,
            jobTitle: nil,
            sameAs: nil,
            logo: .init(id: SiteMeta.absoluteImageURL(for: SiteMeta.defaultImage)),
            founder: .init(id: SiteMeta.authorID),
            publisher: nil,
            author: nil
        )

        let website = Entity(
            id: SiteMeta.websiteID,
            type: "WebSite",
            name: "Accessibility up to 11!",
            alternateName: nil,
            url: SiteMeta.baseURL + "/",
            description: SiteMeta.defaultDescription,
            inLanguage: "en",
            jobTitle: nil,
            sameAs: nil,
            logo: nil,
            founder: nil,
            publisher: .init(id: SiteMeta.organizationID),
            author: .init(id: SiteMeta.authorID)
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.withoutEscapingSlashes]
        guard let data = try? encoder.encode(Graph(graph: [website, organization, author])),
              let output = String(data: data, encoding: .utf8)
        else {
            return ""
        }
        return output
    }
}
