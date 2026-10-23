struct AppPressKit {
    let appSlug: String
    let tagline: String
    let productURL: String
    let storeURL: String
    let headerIconPath: String?
    let archive: AppPressDownload?
    let actions: [AppPressAction]
    let facts: [AppPressFact]
    let recognitionTitle: String
    let recognitionBanner: FeaturedBannerImage?
    let about: AppPressAbout
    let demoVideo: AppPressVideo?
    let features: [AppPressFeature]
    let screenshots: AppPressMediaSection?
    let icons: AppPressIconSection?
    let developer: AppPressDeveloper?
    let additionalMediaSections: [AppPressMediaSection]
    let localizedSummary: AppPressLocalizedSummary?
}

struct AppPressDownload {
    let title: String
    let path: String
    let filename: String
}

struct AppPressAction {
    let title: String
    let target: String
}

struct AppPressFact {
    let label: String
    let value: AppPressParagraph

    init(_ label: String, _ value: String) {
        self.label = label
        self.value = AppPressParagraph(value)
    }

    init(_ label: String, value: AppPressParagraph) {
        self.label = label
        self.value = value
    }
}

struct AppPressAbout {
    let oneSentence: AppPressParagraph
    let inBrief: [AppPressParagraph]
    let storyLead: String?
    let story: [AppPressParagraph]
}

struct AppPressVideo {
    let title: String
    let description: String
    let youTubeID: String
    let watchURL: String
}

struct AppPressFeature {
    let title: String
    let description: String
}

struct AppPressMediaSection {
    let title: String
    let intro: [AppPressParagraph]
    let root: String
    let kind: String
    let items: [AppPressMedia]
    let columnWidth: Int
}

struct AppPressMedia {
    let filename: String
    let title: String
    let details: String?
    let alt: String
}

struct AppPressIconSection {
    let intro: [AppPressParagraph]
    let downloads: [AppPressDownload]
}

struct AppPressDeveloper {
    let bio: [AppPressParagraph]
    let linksTitle: String
    let links: [AppPressAction]
    let contactTitle: String
    let photo: AppPressPhoto?
}

struct AppPressPhoto {
    let path: String
    let fullResolutionPath: String
    let filename: String
    let alt: String
    let caption: String
}

struct AppPressLocalizedSummary {
    let id: String
    let title: String
    let language: String
    let paragraphs: [AppPressParagraph]
    let links: [AppPressAction]
}

struct AppPressParagraph {
    let fragments: [AppPressFragment]
    let language: String?

    init(_ text: String, language: String? = nil) {
        self.fragments = [.text(text)]
        self.language = language
    }

    init(fragments: [AppPressFragment], language: String? = nil) {
        self.fragments = fragments
        self.language = language
    }
}

enum AppPressFragment {
    case text(String)
    case link(title: String, target: String)
}

enum AppPressKits {
    static let all: [AppPressKit] = [.xarra, .retroRapid]

    static var appSlugs: Set<String> {
        Set(all.map(\.appSlug))
    }

    static func kit(for appSlug: String) -> AppPressKit? {
        all.first { $0.appSlug == appSlug }
    }
}
