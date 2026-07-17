import Foundation

/// Lightweight frontmatter reader used by post-publish sitemap generation.
/// Ignite's `Article` environment is unavailable outside page rendering.
struct BlogSitemapEntry {
    let path: String
    let title: String
    let date: Date
    let image: String?

    static func loadAll() -> [BlogSitemapEntry] {
        let fileManager = FileManager.default
        let postsDirectory = URL(fileURLWithPath: fileManager.currentDirectoryPath)
            .appendingPathComponent("Content/post")

        guard let fileURLs = try? fileManager.contentsOfDirectory(
            at: postsDirectory,
            includingPropertiesForKeys: nil
        ) else {
            return []
        }

        return fileURLs
            .filter { $0.pathExtension == "md" }
            .compactMap(parse(at:))
            .sorted { $0.date > $1.date }
    }

    /// Blog tag pages Ignite writes under `Build/tags`.
    static func blogTagPaths() -> [String] {
        let fileManager = FileManager.default
        let tagsDirectory = URL(fileURLWithPath: fileManager.currentDirectoryPath)
            .appendingPathComponent("Build/tags")

        guard let contents = try? fileManager.contentsOfDirectory(
            at: tagsDirectory,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else {
            return ["/tags"]
        }

        var paths = ["/tags"]
        for item in contents {
            var isDirectory: ObjCBool = false
            guard fileManager.fileExists(atPath: item.path, isDirectory: &isDirectory),
                  isDirectory.boolValue
            else {
                continue
            }
            paths.append("/tags/\(item.lastPathComponent)")
        }
        return paths.sorted()
    }

    private static func parse(at url: URL) -> BlogSitemapEntry? {
        guard let content = try? String(contentsOf: url, encoding: .utf8) else {
            return nil
        }

        let components = content.components(separatedBy: "---")
        guard components.count >= 3 else { return nil }

        let frontmatter = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
        var title = url.deletingPathExtension().lastPathComponent
        var date = Date()
        var image: String?

        for line in frontmatter.components(separatedBy: .newlines) {
            let parts = line.components(separatedBy: ": ")
            guard parts.count >= 2 else { continue }
            let key = parts[0].trimmingCharacters(in: .whitespaces)
            let value = parts[1...].joined(separator: ": ").trimmingCharacters(in: .whitespaces)

            switch key {
            case "title":
                title = value
            case "date":
                date = parseDate(value) ?? date
            case "image":
                image = value
            default:
                break
            }
        }

        let slug = url.deletingPathExtension().lastPathComponent
        return BlogSitemapEntry(
            path: "/post/\(slug)",
            title: title,
            date: date,
            image: image
        )
    }

    private static func parseDate(_ value: String) -> Date? {
        let iso8601 = ISO8601DateFormatter()
        iso8601.formatOptions = [.withInternetDateTime]
        if let parsed = iso8601.date(from: value) {
            return parsed
        }

        let withTime = DateFormatter()
        withTime.dateFormat = "yyyy-MM-dd HH:mm"
        withTime.locale = Locale(identifier: "en_US_POSIX")
        withTime.timeZone = TimeZone(identifier: "UTC")
        if let parsed = withTime.date(from: value) {
            return parsed
        }

        let dateOnly = DateFormatter()
        dateOnly.dateFormat = "yyyy-MM-dd"
        dateOnly.locale = Locale(identifier: "en_US_POSIX")
        dateOnly.timeZone = TimeZone(identifier: "UTC")
        return dateOnly.date(from: value)
    }
}
