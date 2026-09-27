#!/usr/bin/env swift
//
//  GenerateRecognitionCards.swift
//  Accessibility up to 11!
//
//  Created by Dani Devesa on 27/09/2026.
//

import Foundation

private let project = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent()
    .deletingLastPathComponent()
private let design = project.appendingPathComponent("Design/Recognition")
private let images = project.appendingPathComponent("Assets/Images/Site/Apps")
private let locale = Locale(identifier: "en_US_POSIX")
private let period = "September 2026"

private struct Rating: Decodable {
    let count: Int
    let average: Double
}

private struct RatingSnapshot: Decodable {
    let totals: [String: Rating]
}

private struct ArtworkURI {
    let laurel: String
    let appStore: String
    let apple: String
}

private struct Point {
    let x: Double
    let y: Double
}

private let starPoints: [Point] = [
    Point(x: 0, y: -31), Point(x: 9, y: -10), Point(x: 32, y: -9),
    Point(x: 14, y: 5), Point(x: 20, y: 29), Point(x: 0, y: 17),
    Point(x: -20, y: 29), Point(x: -14, y: 5), Point(x: -32, y: -9),
    Point(x: -9, y: -10),
]

private enum GeneratorError: LocalizedError {
    case invalidArguments
    case invalidRating(String)
    case stale(URL)
    case rendererFailed(Int32)

    var errorDescription: String? {
        switch self {
        case .invalidArguments:
            "Use --check to verify the cards, or run without arguments to regenerate them."
        case .invalidRating(let app):
            "Missing or invalid worldwide rating for \(app)."
        case .stale(let url):
            "Generated card differs from \(url.path). Run the script to regenerate it."
        case .rendererFailed(let status):
            "ImageMagick failed with exit status \(status)."
        }
    }
}

private func coordinate(_ value: Double) -> String {
    value.formatted(
        .number.precision(.fractionLength(2)).grouping(.never).locale(locale)
    )
}

private func polygonArea(_ points: [Point]) -> Double {
    guard points.count > 2 else { return 0 }
    let doubledArea = points.indices.reduce(0.0) { result, index in
        let next = points[(index + 1) % points.count]
        return result + points[index].x * next.y - next.x * points[index].y
    }
    return abs(doubledArea) / 2
}

private func clippedStar(_ fraction: Double) -> String {
    func clip(at cutoff: Double) -> [Point] {
        var result: [Point] = []
        var previous = starPoints[starPoints.count - 1]
        for current in starPoints {
            let previousInside = previous.x <= cutoff
            let currentInside = current.x <= cutoff
            if previousInside != currentInside {
                let progress = (cutoff - previous.x) / (current.x - previous.x)
                result.append(
                    Point(x: cutoff, y: previous.y + progress * (current.y - previous.y))
                )
            }
            if currentInside { result.append(current) }
            previous = current
        }
        return result
    }

    let points: [Point]
    if fraction >= 1 {
        points = starPoints
    } else {
        let targetArea = polygonArea(starPoints) * fraction
        var lower = -32.0
        var upper = 32.0
        for _ in 0..<30 {
            let midpoint = (lower + upper) / 2
            if polygonArea(clip(at: midpoint)) < targetArea {
                lower = midpoint
            } else {
                upper = midpoint
            }
        }
        points = clip(at: (lower + upper) / 2)
    }
    return "M" + points.map { "\(coordinate($0.x)),\(coordinate($0.y))" }
        .joined(separator: " L") + " Z"
}

private func artwork(_ x: Int, _ y: Int, _ width: Int, _ height: Int, _ uri: String) -> String {
    "<image href=\"\(uri)\" x=\"\(x)\" y=\"\(y)\" width=\"\(width)\" height=\"\(height)\"/>"
}

private func starRow(_ rating: Double) -> String {
    let outline = "M0,-31 L9,-10 L32,-9 L14,5 L20,29 L0,17 L-20,29 L-14,5 L-32,-9 L-9,-10 Z"
    return (0..<5).map { index in
        let fraction = min(1, max(0, rating - Double(index)))
        let x = 408 + 96 * index
        return """
        <g transform="translate(\(x) 457)"><path d="\(clippedStar(fraction))" fill="#000000"/><path d="\(outline)" fill="none" stroke="#000000" stroke-width="3" stroke-linejoin="round"/></g>
        """
    }.joined()
}

private func document(for app: String, rating: Rating, artworkURI: ArtworkURI) -> String {
    let displayedRating = (rating.average * 10).rounded(.toNearestOrEven) / 10
    let ratingText = displayedRating.formatted(
        .number.precision(.fractionLength(1)).grouping(.never).locale(locale)
    )
    let countText = rating.count.formatted(.number.grouping(.automatic).locale(locale))
    let countLabel = "\(countText) App Store rating\(rating.count == 1 ? "" : "s")"
    let laurel = artwork(78, 152, 222, 476, artworkURI.laurel)
    let mirroredLaurel = "<g transform=\"translate(1200 0) scale(-1 1)\">\(laurel)</g>"
    let appStore = artwork(537, 41, 126, 126, artworkURI.appStore)
    let apple = artwork(557, 513, 86, 118, artworkURI.apple)
    let body = """
    \(laurel)\(mirroredLaurel)\(appStore)
    <text x="600" y="375" font-size="206" font-weight="bold" font-family="Georgia" text-anchor="middle" fill="#000000">\(ratingText)</text>
    \(starRow(displayedRating))
    \(apple)
    <text x="600" y="682" font-size="51" font-weight="bold" font-family="Georgia" text-anchor="middle" fill="#000000">\(countLabel)</text>
    <text x="600" y="722" font-size="29" font-family="Georgia" text-anchor="middle" fill="#000000">worldwide</text>
    <text x="600" y="764" font-size="27" font-family="Georgia" text-anchor="middle" fill="#000000">\(app) • \(period)</text>
    """
    let label = "\(app): \(ratingText) out of 5 from \(countLabel) worldwide, \(period)."
    return """
    <svg xmlns="http://www.w3.org/2000/svg" width="1200" height="800" viewBox="0 0 1200 800" role="img" aria-label="\(label)">\(body)</svg>
    """
}

private func render(_ source: URL, to destination: URL) throws {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    process.arguments = ["magick", "-background", "none", source.path, "-strip", destination.path]
    try process.run()
    process.waitUntilExit()
    guard process.terminationStatus == 0 else {
        throw GeneratorError.rendererFailed(process.terminationStatus)
    }
}

private func writeOrCheck(_ data: Data, at destination: URL, checking: Bool) throws {
    if checking {
        guard (try? Data(contentsOf: destination)) == data else {
            throw GeneratorError.stale(destination)
        }
    } else {
        try FileManager.default.createDirectory(
            at: destination.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try data.write(to: destination, options: .atomic)
    }
}

private func imageURI(named name: String) throws -> String {
    let bytes = try Data(contentsOf: design.appendingPathComponent("\(name).png"))
    return "data:image/png;base64," + bytes.base64EncodedString()
}

private func run() throws {
    let arguments = Array(CommandLine.arguments.dropFirst())
    if arguments == ["--help"] || arguments == ["-h"] {
        print("GenerateRecognitionCards.swift [--check]")
        return
    }
    guard arguments.isEmpty || arguments == ["--check"] else {
        throw GeneratorError.invalidArguments
    }
    let checking = arguments == ["--check"]
    let snapshotURL = design.appendingPathComponent("global-ratings-2026-09.json")
    let snapshot = try JSONDecoder().decode(
        RatingSnapshot.self,
        from: Data(contentsOf: snapshotURL)
    )
    let artworkURI = try ArtworkURI(
        laurel: imageURI(named: "laurel"),
        appStore: imageURI(named: "app-store"),
        apple: imageURI(named: "apple")
    )
    let temporary = FileManager.default.temporaryDirectory
        .appendingPathComponent("recognition-cards-\(UUID().uuidString)")
    try FileManager.default.createDirectory(at: temporary, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: temporary) }

    for app in ["Xarra", "RetroRapid", "iMonstickers"] {
        guard let rating = snapshot.totals[app], rating.count > 0,
              rating.average.isFinite, (0...5).contains(rating.average) else {
            throw GeneratorError.invalidRating(app)
        }
        let name = "\(app.lowercased())-global-rating-2026-09"
        let svg = document(for: app, rating: rating, artworkURI: artworkURI)
        let stagedSVG = temporary.appendingPathComponent("\(name).svg")
        let stagedPNG = temporary.appendingPathComponent("\(name).png")
        try svg.write(to: stagedSVG, atomically: true, encoding: .utf8)
        try render(stagedSVG, to: stagedPNG)
        let svgDestination = design.appendingPathComponent("\(name).svg")
        let pngDestination = images.appendingPathComponent(
            "\(app)/GlobalAppStoreRating-2026-09.png"
        )
        try writeOrCheck(Data(contentsOf: stagedSVG), at: svgDestination, checking: checking)
        try writeOrCheck(Data(contentsOf: stagedPNG), at: pngDestination, checking: checking)
        print("\(checking ? "Checked" : "Generated") \(app) recognition card")
    }
}

do {
    try run()
} catch {
    fputs("\(error.localizedDescription)\n", stderr)
    exit(1)
}
