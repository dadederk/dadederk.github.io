import Foundation

#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

enum LogStage: String {
    case build = "Build"
    case socialMetadata = "Social Metadata"

    var emoji: String {
        switch self {
        case .build: "🏗️"
        case .socialMetadata: "🔎"
        }
    }
}

enum Log {
    static func step(_ stage: LogStage, _ message: String) {
        line("⏳ \(stage.emoji) \(stage.rawValue): \(message)")
    }

    static func success(_ stage: LogStage, _ message: String) {
        line("✅ \(stage.emoji) \(stage.rawValue): \(message)")
    }

    static func failure(_ stage: LogStage, _ message: String) {
        line("❌ \(stage.emoji) \(stage.rawValue): \(message)")
    }

    static func detail(_ message: String) {
        line("   • \(message)")
    }

    private static func line(_ message: String) {
        print(message)
        fflush(stdout)
    }
}

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
    let maxDescriptionLength: Int?
}

struct PageResult {
    let label: String
    let relativePath: String
    let failures: [String]
}

let fallbackImagePath = "/Images/Site/Global/LogoShare.png"
let fallbackImageURL = "https://accessibilityupto11.com\(fallbackImagePath)"

func main() -> Int32 {
    let projectDirectory = resolveProjectDirectory()
    let buildDirectory = resolveBuildDirectory(projectDirectory: projectDirectory)
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
        Log.failure(.build, "failed to prepare generated site: \(error.localizedDescription)")
        return 1
    }

    let checks = pageChecks()
    Log.step(.socialMetadata, "validating \(checks.count) representative pages")
    let results = checks.map { check in
        let result = runChecks(for: check, buildDirectory: buildDirectory)
        printResult(result)
        return result
    }
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
        Log.success(.socialMetadata, "using existing Build directory")
        Log.detail(buildDirectory.path)
        return
    }

    if !allowAutoBuild {
        throw NSError(domain: "CheckSocialMeta", code: 2, userInfo: [
            NSLocalizedDescriptionKey: """
            Build directory not found at \(buildDirectory.path).
            Run `swift run` first, set SOCIAL_META_BUILD_DIR, or call this script with --build.
            """
        ])
    }

    Log.step(.build, "running swift run before validation")
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

    Log.success(.build, "generated site before validation")
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

    if ogImages.count != 1 {
        return "Expected exactly 1 og:image tag, found \(ogImages.count)."
    }

    if twitterImages.count != 1 {
        return "Expected exactly 1 twitter:image tag, found \(twitterImages.count)."
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

func assertHasDescription(
    in tags: [MetaTagEntry],
    expectedSubstring: String?,
    maxLength: Int?
) -> String? {
    let htmlDescriptions = tags.filter { $0.name == "description" }
    let ogDescriptions = tags.filter { $0.property == "og:description" }
    let twitterDescriptions = tags.filter { $0.name == "twitter:description" }

    for (label, entries) in [
        ("description", htmlDescriptions),
        ("og:description", ogDescriptions),
        ("twitter:description", twitterDescriptions)
    ] {
        if entries.count != 1 {
            return "Expected exactly 1 \(label) tag, found \(entries.count)."
        }

        if entries.first?.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty != false {
            return "Missing or empty \(label) tag."
        }
    }

    let htmlDescription = htmlDescriptions[0].content.trimmingCharacters(in: .whitespacesAndNewlines)
    let ogDescription = ogDescriptions[0].content.trimmingCharacters(in: .whitespacesAndNewlines)
    let twitterDescription = twitterDescriptions[0].content.trimmingCharacters(in: .whitespacesAndNewlines)

    if htmlDescription != ogDescription || htmlDescription != twitterDescription {
        return "Description tags do not match across HTML, OG, and Twitter."
    }

    if let maxLength, htmlDescription.count > maxLength {
        return "Description length \(htmlDescription.count) exceeds maximum \(maxLength)."
    }

    if let expectedSubstring {
        if !htmlDescription.localizedCaseInsensitiveContains(expectedSubstring) {
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

        if let failure = assertHasDescription(
            in: tags,
            expectedSubstring: check.expectedDescriptionSubstring,
            maxLength: check.maxDescriptionLength
        ) {
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

func printResult(_ result: PageResult) {
    if result.failures.isEmpty {
        Log.success(.socialMetadata, "\(result.label) (\(result.relativePath))")
    } else {
        Log.failure(.socialMetadata, "\(result.label) (\(result.relativePath))")
        for failure in result.failures {
            Log.detail(failure)
        }
    }
}

func printSummary(_ results: [PageResult]) {
    let passed = results.filter { $0.failures.isEmpty }
    let failed = results.filter { !$0.failures.isEmpty }

    let summary = "\(passed.count) passed, \(failed.count) failed"
    if failed.isEmpty {
        Log.success(.socialMetadata, summary)
    } else {
        Log.failure(.socialMetadata, summary)
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
            requiresAbsoluteImageURLs: true,
            maxDescriptionLength: 160
        ),
        PageCheck(
            label: "365 post without lead image uses fallback",
            relativePath: "365-days-ios-accessibility/day-002/index.html",
            expectsFallbackImage: true,
            expectedImageSubstring: nil,
            expectedDescriptionSubstring: nil,
            requiresAbsoluteImageURLs: true,
            maxDescriptionLength: 160
        ),
        PageCheck(
            label: "App page uses app icon",
            relativePath: "apps/xarra/index.html",
            expectsFallbackImage: false,
            expectedImageSubstring: "XarraIcon.png",
            expectedDescriptionSubstring: nil,
            requiresAbsoluteImageURLs: true,
            maxDescriptionLength: nil
        ),
        PageCheck(
            label: "About page has curated metadata",
            relativePath: "about/index.html",
            expectsFallbackImage: false,
            expectedImageSubstring: "dani.jpg",
            expectedDescriptionSubstring: "Daniel Devesa Derksen-Staats",
            requiresAbsoluteImageURLs: true,
            maxDescriptionLength: 160
        ),
        PageCheck(
            label: "365 tag page has route-aware summary",
            relativePath: "365-days-ios-accessibility/tag/accessibility/index.html",
            expectsFallbackImage: false,
            expectedImageSubstring: nil,
            expectedDescriptionSubstring: "#365DaysIOSAccessibility post",
            requiresAbsoluteImageURLs: true,
            maxDescriptionLength: 160
        ),
        PageCheck(
            label: "Blog post has share-safe image",
            relativePath: "post/2026-02-22-01/index.html",
            expectsFallbackImage: false,
            expectedImageSubstring: "RetroRapidWatch.png",
            expectedDescriptionSubstring: nil,
            requiresAbsoluteImageURLs: true,
            maxDescriptionLength: 160
        ),
        PageCheck(
            label: "Blog post with long intro uses truncated description",
            relativePath: "post/2020-08-11-01/index.html",
            expectsFallbackImage: false,
            expectedImageSubstring: "Testing.png",
            expectedDescriptionSubstring: "starts and ends with testing",
            requiresAbsoluteImageURLs: true,
            maxDescriptionLength: 160
        ),
        PageCheck(
            label: "Ignite tag page falls back to logo image",
            relativePath: "tags/accessibility/index.html",
            expectsFallbackImage: true,
            expectedImageSubstring: nil,
            expectedDescriptionSubstring: nil,
            requiresAbsoluteImageURLs: true,
            maxDescriptionLength: nil
        )
    ]
}

func projectDirectoryURL() -> URL {
    URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()
        .deletingLastPathComponent()
}

func resolveProjectDirectory() -> URL {
    if let override = ProcessInfo.processInfo.environment["SOCIAL_META_PROJECT_DIR"], !override.isEmpty {
        return URL(fileURLWithPath: override)
    }

    let cwd = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    if FileManager.default.fileExists(atPath: cwd.appendingPathComponent("Package.swift").path) {
        return cwd
    }

    return projectDirectoryURL()
}

func resolveBuildDirectory(projectDirectory: URL) -> URL {
    if let override = ProcessInfo.processInfo.environment["SOCIAL_META_BUILD_DIR"], !override.isEmpty {
        return URL(fileURLWithPath: override)
    }

    let cwdBuild = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent("Build")
    if FileManager.default.fileExists(atPath: cwdBuild.path) {
        return cwdBuild
    }

    return projectDirectory.appendingPathComponent("Build")
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
