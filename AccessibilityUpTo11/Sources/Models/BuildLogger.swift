import Foundation

#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

enum BuildStage: String {
    case build = "Build"
    case rss = "RSS"
    case sitemap = "Sitemap"
    case imageSitemap = "Image Sitemap"
    case universalLinks = "Universal Links"
    case socialMetadata = "Social Metadata"
    case agentDiscovery = "Agent Discovery"

    var emoji: String {
        switch self {
        case .build: "🏗️"
        case .rss: "📝"
        case .sitemap: "🗺️"
        case .imageSitemap: "🖼️"
        case .universalLinks: "🔗"
        case .socialMetadata: "🔎"
        case .agentDiscovery: "🤖"
        }
    }
}

enum BuildLogger {
    static func step(_ stage: BuildStage, _ message: String) {
        line("⏳ \(stage.emoji) \(stage.rawValue): \(message)")
    }

    static func success(_ stage: BuildStage, _ message: String) {
        line("✅ \(stage.emoji) \(stage.rawValue): \(message)")
    }

    static func warning(_ stage: BuildStage, _ message: String) {
        line("⚠️ \(stage.emoji) \(stage.rawValue): \(message)")
    }

    static func failure(_ stage: BuildStage, _ message: String) {
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
