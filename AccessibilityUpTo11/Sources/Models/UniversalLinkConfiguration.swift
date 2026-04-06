import Foundation

struct UniversalLinkRoute {
    let slug: String
    let appID: String
    let additionalPaths: [String]

    var openPath: String {
        "/apps/\(slug)/open"
    }

    var allPaths: [String] {
        [openPath] + additionalPaths
    }
}

enum UniversalLinkConfiguration {
    static let routes: [UniversalLinkRoute] = [
        UniversalLinkRoute(
            slug: "retrorapid",
            appID: "PV9S9FTZF2.com.accessibilityUpTo11.RetroRacing",
            additionalPaths: []
        ),
        UniversalLinkRoute(
            slug: "xarra",
            appID: "PV9S9FTZF2.com.accessibilityUpTo11.Xarra",
            additionalPaths: ["/xarra/open-latest-share"]
        )
    ]

    static var openPageSlugs: [String] {
        routes.map(\.slug)
    }

    static func publishAASA(projectDirectory: URL) throws {
        let resourcesAASA = projectDirectory
            .appendingPathComponent("Resources")
            .appendingPathComponent(".well-known")
            .appendingPathComponent("apple-app-site-association")

        let buildAASA = projectDirectory
            .appendingPathComponent("Build")
            .appendingPathComponent(".well-known")
            .appendingPathComponent("apple-app-site-association")

        let data = try buildAASAData()
        let fileManager = FileManager.default

        try fileManager.createDirectory(
            at: resourcesAASA.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try data.write(to: resourcesAASA, options: .atomic)

        try fileManager.createDirectory(
            at: buildAASA.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try data.write(to: buildAASA, options: .atomic)
    }

    private static func buildAASAData() throws -> Data {
        let file = AppleAppSiteAssociation(
            applinks: .init(
                apps: [],
                details: routes.map { route in
                    .init(
                        appID: route.appID,
                        paths: normalizedPaths(route.allPaths)
                    )
                }
            )
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(file)
    }

    private static func normalizedPaths(_ paths: [String]) -> [String] {
        var seen = Set<String>()
        var result: [String] = []

        for path in paths {
            let normalized = normalize(path)
            if normalized.isEmpty { continue }
            if seen.insert(normalized).inserted {
                result.append(normalized)
            }

            if shouldAddTrailingSlashVariant(for: normalized) {
                let trailingSlash = normalized + "/"
                if seen.insert(trailingSlash).inserted {
                    result.append(trailingSlash)
                }
            }
        }

        return result
    }

    private static func normalize(_ path: String) -> String {
        let trimmed = path.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "" }

        let normalized = "/" + trimmed.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        return normalized == "/" && trimmed != "/" ? "" : normalized
    }

    private static func shouldAddTrailingSlashVariant(for path: String) -> Bool {
        guard path != "/" else { return false }
        guard !path.hasSuffix("/") else { return false }
        guard !path.contains("*"), !path.contains("?") else { return false }
        return true
    }
}

private struct AppleAppSiteAssociation: Encodable {
    let applinks: AppLinks

    struct AppLinks: Encodable {
        let apps: [String]
        let details: [Detail]
    }

    struct Detail: Encodable {
        let appID: String
        let paths: [String]
    }
}
