import Foundation

/// Rewrites links to directory-backed HTML pages so users and crawlers go
/// directly to the canonical trailing-slash URL without a GitHub Pages 301.
enum CanonicalURLPublisher {
    static func publish(buildDirectory: URL) throws {
        BuildLogger.step(.build, "canonicalizing internal page links")
        let files = htmlFiles(in: buildDirectory)
        var changed = 0

        for file in files {
            let html = try String(contentsOf: file, encoding: .utf8)
            let rewritten = rewrite(html: html, buildDirectory: buildDirectory)
            guard rewritten != html else { continue }
            try rewritten.write(to: file, atomically: true, encoding: .utf8)
            changed += 1
        }

        BuildLogger.detail("Canonicalized links in \(changed) of \(files.count) HTML files")
    }

    static func rewrite(html: String, buildDirectory: URL) -> String {
        guard let regex = try? NSRegularExpression(
            pattern: #"href="([^"]+)""#,
            options: [.caseInsensitive]
        ) else {
            return html
        }

        let fullRange = NSRange(html.startIndex..<html.endIndex, in: html)
        let matches = regex.matches(in: html, range: fullRange)
        var output = html

        for match in matches.reversed() {
            guard let valueRange = Range(match.range(at: 1), in: html) else { continue }
            let value = String(html[valueRange])
            guard let canonical = canonicalTarget(for: value, buildDirectory: buildDirectory),
                  canonical != value,
                  let outputRange = Range(match.range(at: 1), in: output)
            else {
                continue
            }
            output.replaceSubrange(outputRange, with: canonical)
        }

        return output
    }

    private static func canonicalTarget(for target: String, buildDirectory: URL) -> String? {
        guard target.hasPrefix("/"), !target.hasPrefix("//"), target != "/" else {
            return nil
        }

        let splitIndex = target.firstIndex { $0 == "?" || $0 == "#" }
        let path = splitIndex.map { String(target[..<$0]) } ?? target
        let suffix = splitIndex.map { String(target[$0...]) } ?? ""

        guard !path.hasSuffix("/") else { return nil }
        let lastComponent = path.split(separator: "/").last.map(String.init) ?? ""
        guard !lastComponent.contains(".") else { return nil }

        let relativePath = String(path.dropFirst())
        let indexFile = buildDirectory
            .appendingPathComponent(relativePath, isDirectory: true)
            .appendingPathComponent("index.html")
        guard FileManager.default.fileExists(atPath: indexFile.path) else { return nil }

        return path + "/" + suffix
    }

    private static func htmlFiles(in directory: URL) -> [URL] {
        guard let enumerator = FileManager.default.enumerator(
            at: directory,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }

        return enumerator.compactMap { item in
            guard let url = item as? URL, url.pathExtension.lowercased() == "html" else {
                return nil
            }
            return url
        }
    }
}
