import Foundation

/// Ignite marks a nav link current only when its href equals the page path.
/// App terms, privacy, and press pages still belong to Apps.
enum NavigationSectionMarker {
    static func markingCurrentSections(in html: String) -> String {
        guard let path = currentPagePath(in: html), isAppsSection(path) else {
            return html
        }

        let plain = #"<a href="/apps" class="nav-link text-nowrap">Apps</a>"#
        let current = #"<a href="/apps" class="nav-link active text-nowrap" aria-current="page">Apps</a>"#
        guard html.contains(plain) else { return html }
        return html.replacingOccurrences(of: plain, with: current)
    }

    static func markBuiltSite(at buildDirectory: URL) throws {
        let files = try htmlFiles(in: buildDirectory)
        for file in files {
            let html = try String(contentsOf: file, encoding: .utf8)
            let marked = markingCurrentSections(in: html)
            guard marked != html else { continue }
            try marked.write(to: file, atomically: true, encoding: .utf8)
        }
    }

    private static func isAppsSection(_ path: String) -> Bool {
        path == "/apps" || path.hasPrefix("/apps/")
    }

    private static func currentPagePath(in html: String) -> String? {
        guard let range = html.range(of: #"data-current-page="[^"]+""#, options: .regularExpression) else {
            return nil
        }
        let token = html[range]
        guard let valueStart = token.range(of: "=\""),
              let valueEnd = token.range(of: "\"", options: .backwards) else {
            return nil
        }
        return String(token[valueStart.upperBound..<valueEnd.lowerBound])
    }

    private static func htmlFiles(in directory: URL) throws -> [URL] {
        guard let enumerator = FileManager.default.enumerator(
            at: directory,
            includingPropertiesForKeys: nil
        ) else {
            return []
        }

        var files: [URL] = []
        for case let file as URL in enumerator where file.pathExtension == "html" {
            files.append(file)
        }
        return files
    }
}
