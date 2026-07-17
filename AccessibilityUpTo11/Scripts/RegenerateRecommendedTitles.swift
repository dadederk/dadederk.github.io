#!/usr/bin/env swift
import Foundation

let projectDirectory = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent()
    .deletingLastPathComponent()
let sourceFile = projectDirectory.appendingPathComponent("Days365Content/recommended-titles.md")
let outputFile = projectDirectory.appendingPathComponent("Sources/Models/RecommendedTitles.generated.swift")

guard let content = try? String(contentsOf: sourceFile, encoding: .utf8) else {
    fputs("Missing \(sourceFile.path)\n", stderr)
    exit(1)
}

var titles: [Int: String] = [:]

for line in content.components(separatedBy: .newlines) where line.hasPrefix("|") {
    let columns = line
        .trimmingCharacters(in: CharacterSet(charactersIn: "|"))
        .split(separator: "|", omittingEmptySubsequences: false)
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    guard columns.count >= 2, let day = Int(columns[0]), !columns[1].isEmpty, !columns[0].hasPrefix("---") else {
        continue
    }
    titles[day] = normalize(columns[1])
}

let bulletPattern = #"^- Day (\d+): (.+)$"#
if let regex = try? NSRegularExpression(pattern: bulletPattern) {
    let range = NSRange(content.startIndex..<content.endIndex, in: content)
    for match in regex.matches(in: content, options: [], range: range) {
        guard
            let dayRange = Range(match.range(at: 1), in: content),
            let titleRange = Range(match.range(at: 2), in: content),
            let day = Int(content[dayRange])
        else { continue }
        titles[day] = normalize(String(content[titleRange]))
    }
}

var lines = [
    "import Foundation",
    "",
    "/// Curated 365 Days topic titles (generated from `Days365Content/recommended-titles.md`).",
    "enum RecommendedTitles {",
    "    static let byDay: [Int: String] = ["
]

for day in titles.keys.sorted() {
    let escaped = titles[day]!
        .replacingOccurrences(of: "\\", with: "\\\\")
        .replacingOccurrences(of: "\"", with: "\\\"")
    lines.append("        \(day): \"\(escaped)\",")
}

lines += [
    "    ]",
    "}",
    ""
]

try lines.joined(separator: "\n").write(to: outputFile, atomically: true, encoding: .utf8)
print("Wrote \(titles.count) titles to \(outputFile.path)")

func normalize(_ title: String) -> String {
    title
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
}
