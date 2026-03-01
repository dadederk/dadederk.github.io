import Foundation

struct MetaTagEntry {
    let name: String?
    let property: String?
    let content: String
}

struct PageCheck {
    let label: String
    let relativePath: String
    let expectsFallbackImage: Bool
    let expectedImageSubstring: String?
    let expectedDescriptionSubstring: String?
    let requiresAbsoluteImageURLs: Bool
}

struct PageResult {
    let label: String
    let relativePath: String
    let failures: [String]
}

let fallbackImagePath = "/Images/Site/Global/LogoShare.png"
let fallbackImageURL = "https://accessibilityupto11.com\(fallbackImagePath)"

func main() -> Int32 {
    let projectDirectory = projectDirectoryURL()
    let buildDirectory = projectDirectory.appendingPathComponent("Build")
    let shouldBuild = CommandLine.arguments.contains("--build")
    let noBuild = CommandLine.arguments.contains("--no-build")

    do {
        try buildSiteIfNeeded(
            forceBuild: shouldBuild,
            allowAutoBuild: !noBuild,
            projectDirectory: projectDirectory,
            buildDirectory: buildDirectory
        )
    } catch {
        print("Failed to build site: \(error)")
        return 1
    }

    let checks = pageChecks()
    let results = checks.map { runChecks(for: $0, buildDirectory: buildDirectory) }
    printSummary(results)

    let hasFailures = results.contains { !$0.failures.isEmpty }
    return hasFailures ? 1 : 0
}

func buildSiteIfNeeded(
    forceBuild: Bool,
    allowAutoBuild: Bool,
    projectDirectory: URL,
    buildDirectory: URL
) throws {
    if !forceBuild && FileManager.default.fileExists(atPath: buildDirectory.path) {
        print("Using existing Build directory at \(buildDirectory.path)")
        return
    }

    if !allowAutoBuild {
        throw NSError(domain: "CheckSocialMeta", code: 2, userInfo: [
            NSLocalizedDescriptionKey: "Build directory not found at \(buildDirectory.path). Run `swift run` first or call this script with --build."
        ])
    }

    print("Building site with swift run")
    let process = Process()
    process.currentDirectoryURL = projectDirectory
    process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    process.arguments = ["swift", "run"]

    var environment = ProcessInfo.processInfo.environment
    environment["SWIFTPM_MODULECACHE_OVERRIDE"] = "/tmp/swiftpm-module-cache"
    environment["CLANG_MODULE_CACHE_PATH"] = "/tmp/clang-module-cache"
    environment["SKIP_SOCIAL_META_CHECK"] = "1"
    process.environment = environment

    try process.run()
    process.waitUntilExit()

    if process.terminationStatus != 0 {
        throw NSError(domain: "CheckSocialMeta", code: Int(process.terminationStatus), userInfo: [
            NSLocalizedDescriptionKey: "swift run exited with status \(process.terminationStatus)"
        ])
    }
}

func loadHTML(at fileURL: URL) throws -> String {
    try String(contentsOf: fileURL, encoding: .utf8)
}

func extractMetaTags(from html: String) -> [MetaTagEntry] {
    guard let regex = try? NSRegularExpression(pattern: #"<meta\s+[^>]*>"#, options: [.caseInsensitive]) else {
        return []
    }

    let nsRange = NSRange(html.startIndex..<html.endIndex, in: html)
    let matches = regex.matches(in: html, options: [], range: nsRange)

    return matches.compactMap { match in
        guard let range = Range(match.range, in: html) else { return nil }
        let tagString = String(html[range])
        let content = extractAttribute(named: "content", in: tagString) ?? ""
        let name = extractAttribute(named: "name", in: tagString)
        let property = extractAttribute(named: "property", in: tagString)
        return MetaTagEntry(name: name, property: property, content: content)
    }
}

func assertSingleCanonical(in html: String) -> String? {
    guard let regex = try? NSRegularExpression(pattern: #"<link\s+[^>]*rel="canonical"[^>]*>"#, options: [.caseInsensitive]) else {
        return "Could not compile canonical regex."
    }

    let nsRange = NSRange(html.startIndex..<html.endIndex, in: html)
    let matches = regex.matches(in: html, options: [], range: nsRange)

    if matches.count != 1 {
        return "Expected exactly 1 canonical link, found \(matches.count)."
    }

    return nil
}

func assertSingleTwitterCard(in tags: [MetaTagEntry]) -> String? {
    let cards = tags.filter { $0.name == "twitter:card" }
    if cards.count != 1 {
        return "Expected exactly 1 twitter:card tag, found \(cards.count)."
    }

    return nil
}

func assertHasImageTags(in tags: [MetaTagEntry], requiresAbsoluteImageURLs: Bool) -> String? {
    let ogImages = tags.filter { $0.property == "og:image" }
    let twitterImages = tags.filter { $0.name == "twitter:image" }

    if ogImages.isEmpty {
        return "Missing og:image tag."
    }

    if twitterImages.isEmpty {
        return "Missing twitter:image tag."
    }

    if requiresAbsoluteImageURLs {
        let hasAbsoluteOG = ogImages.contains { $0.content.hasPrefix("https://") }
        let hasAbsoluteTwitter = twitterImages.contains { $0.content.hasPrefix("https://") }

        if !hasAbsoluteOG {
            return "Expected at least one absolute og:image URL."
        }

        if !hasAbsoluteTwitter {
            return "Expected at least one absolute twitter:image URL."
        }
    }

    return nil
}

func assertHasAccessibleImageAlt(in tags: [MetaTagEntry]) -> String? {
    let ogAlt = tags.first { $0.property == "og:image:alt" }?.content.trimmingCharacters(in: .whitespacesAndNewlines)
    let twitterAlt = tags.first { $0.name == "twitter:image:alt" }?.content.trimmingCharacters(in: .whitespacesAndNewlines)

    if ogAlt?.isEmpty != false {
        return "Missing or empty og:image:alt tag."
    }

    if twitterAlt?.isEmpty != false {
        return "Missing or empty twitter:image:alt tag."
    }

    return nil
}

func assertHasDescription(in tags: [MetaTagEntry], expectedSubstring: String?) -> String? {
    let ogDescription = tags.first { $0.property == "og:description" }?.content.trimmingCharacters(in: .whitespacesAndNewlines)
    let twitterDescription = tags.first { $0.name == "twitter:description" }?.content.trimmingCharacters(in: .whitespacesAndNewlines)

    if ogDescription?.isEmpty != false {
        return "Missing or empty og:description tag."
    }

    if twitterDescription?.isEmpty != false {
        return "Missing or empty twitter:description tag."
    }

    if let expectedSubstring {
        let matchesOG = ogDescription?.localizedCaseInsensitiveContains(expectedSubstring) == true
        let matchesTwitter = twitterDescription?.localizedCaseInsensitiveContains(expectedSubstring) == true
        if !matchesOG && !matchesTwitter {
            return "Description does not contain expected text: \(expectedSubstring)"
        }
    }

    return nil
}

func assertUsesFallbackImageWhenExpected(
    in tags: [MetaTagEntry],
    expectsFallbackImage: Bool,
    expectedImageSubstring: String?
) -> String? {
    let imageValues = tags
        .filter { $0.property == "og:image" || $0.name == "twitter:image" }
        .map(\.content)

    if expectsFallbackImage {
        let usesFallback = imageValues.contains { $0.contains(fallbackImagePath) || $0 == fallbackImageURL }
        if !usesFallback {
            return "Expected fallback image \(fallbackImagePath), but it was not found."
        }
    }

    if let expectedImageSubstring {
        let containsExpectedImage = imageValues.contains { $0.contains(expectedImageSubstring) }
        if !containsExpectedImage {
            return "Expected image containing '\(expectedImageSubstring)' was not found."
        }
    }

    return nil
}

func runChecks(for check: PageCheck, buildDirectory: URL) -> PageResult {
    let fileURL = buildDirectory.appendingPathComponent(check.relativePath)
    var failures: [String] = []

    do {
        let html = try loadHTML(at: fileURL)
        let tags = extractMetaTags(from: html)

        if let failure = assertSingleCanonical(in: html) {
            failures.append(failure)
        }

        if let failure = assertSingleTwitterCard(in: tags) {
            failures.append(failure)
        }

        if let failure = assertHasImageTags(in: tags, requiresAbsoluteImageURLs: check.requiresAbsoluteImageURLs) {
            failures.append(failure)
        }

        if let failure = assertHasAccessibleImageAlt(in: tags) {
            failures.append(failure)
        }

        if let failure = assertHasDescription(in: tags, expectedSubstring: check.expectedDescriptionSubstring) {
            failures.append(failure)
        }

        if let failure = assertUsesFallbackImageWhenExpected(
            in: tags,
            expectsFallbackImage: check.expectsFallbackImage,
            expectedImageSubstring: check.expectedImageSubstring
        ) {
            failures.append(failure)
        }
    } catch {
        failures.append("Failed to load page at \(check.relativePath): \(error.localizedDescription)")
    }

    return PageResult(label: check.label, relativePath: check.relativePath, failures: failures)
}

func printSummary(_ results: [PageResult]) {
    let passed = results.filter { $0.failures.isEmpty }
    let failed = results.filter { !$0.failures.isEmpty }

    print("")
    print("Social metadata check summary")
    print("Passed: \(passed.count)")
    print("Failed: \(failed.count)")

    for result in passed {
        print("PASS \(result.label) (\(result.relativePath))")
    }

    for result in failed {
        print("FAIL \(result.label) (\(result.relativePath))")
        for failure in result.failures {
            print("  - \(failure)")
        }
    }
}

func pageChecks() -> [PageCheck] {
    [
        PageCheck(
            label: "365 post with lead image",
            relativePath: "365-days-ios-accessibility/day-233/index.html",
            expectsFallbackImage: false,
            expectedImageSubstring: "imageDay233.jpeg",
            expectedDescriptionSubstring: nil,
            requiresAbsoluteImageURLs: true
        ),
        PageCheck(
            label: "365 post without lead image uses fallback",
            relativePath: "365-days-ios-accessibility/day-002/index.html",
            expectsFallbackImage: true,
            expectedImageSubstring: nil,
            expectedDescriptionSubstring: nil,
            requiresAbsoluteImageURLs: true
        ),
        PageCheck(
            label: "App page uses app icon",
            relativePath: "apps/xarra/index.html",
            expectsFallbackImage: false,
            expectedImageSubstring: "XarraIcon.png",
            expectedDescriptionSubstring: nil,
            requiresAbsoluteImageURLs: true
        ),
        PageCheck(
            label: "About page has curated metadata",
            relativePath: "about/index.html",
            expectsFallbackImage: false,
            expectedImageSubstring: "dani.jpg",
            expectedDescriptionSubstring: "Daniel Devesa Derksen-Staats",
            requiresAbsoluteImageURLs: true
        ),
        PageCheck(
            label: "365 tag page has route-aware summary",
            relativePath: "365-days-ios-accessibility/tag/accessibility/index.html",
            expectsFallbackImage: false,
            expectedImageSubstring: nil,
            expectedDescriptionSubstring: "#365DaysIOSAccessibility post",
            requiresAbsoluteImageURLs: true
        ),
        PageCheck(
            label: "Blog post has share-safe image",
            relativePath: "post/2026-02-22-01/index.html",
            expectsFallbackImage: false,
            expectedImageSubstring: "RetroRapidWatch.png",
            expectedDescriptionSubstring: nil,
            requiresAbsoluteImageURLs: true
        ),
        PageCheck(
            label: "Ignite tag page falls back to logo image",
            relativePath: "tags/accessibility/index.html",
            expectsFallbackImage: true,
            expectedImageSubstring: nil,
            expectedDescriptionSubstring: nil,
            requiresAbsoluteImageURLs: true
        )
    ]
}

func projectDirectoryURL() -> URL {
    URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()
        .deletingLastPathComponent()
}

func extractAttribute(named name: String, in tag: String) -> String? {
    let pattern = #"\#(name)="([^"]*)""#
    guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
        return nil
    }

    let nsRange = NSRange(tag.startIndex..<tag.endIndex, in: tag)
    guard let match = regex.firstMatch(in: tag, options: [], range: nsRange),
          let range = Range(match.range(at: 1), in: tag)
    else {
        return nil
    }

    return String(tag[range])
}

exit(main())
