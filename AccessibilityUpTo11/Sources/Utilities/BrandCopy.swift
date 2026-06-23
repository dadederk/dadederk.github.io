import Foundation
import Ignite

/// Branding helpers for product names that end with an italic `!` mark.
///
/// ## Brand mark rules (Accessibility up to 11! site)
///
/// | Context | Treatment |
/// |---|---|
/// | Nav titles, app names, buttons, card titles | `Name!` with italic `!` in rendered UI |
/// | Mid-sentence UI labels when easy (e.g. "Rate Xarra!", "Why Xarra!?") | Keep the brand mark; italicize `!`; keep trailing punctuation (`?`, `.`, etc.) |
/// | Plain strings, metadata, `aria-label`, JSON prose | Plain `!` or no mark when it reads more naturally |
/// | App Store listing names, slugs, bundle IDs | No `!` |
///
/// Prefer `titleText`, `inlineTitle`, `linkedInlineTitle`, `phrase`, and `whySectionTitle(for:)`
/// instead of hand-rolling `<em>` markup.
enum BrandCopy {
    /// Returns the plain spoken name, ensuring a trailing brand mark when expected.
    static func spokenName(_ title: String) -> String {
        title.hasSuffix("!") ? title : "\(title)!"
    }

    /// Returns the name without the brand mark.
    static func baseName(_ title: String) -> String {
        title.hasSuffix("!") ? String(title.dropLast()) : title
    }

    /// URL slug for app pages. Brand marks are never part of slugs.
    static func slug(from title: String) -> String {
        baseName(title).lowercased().replacingOccurrences(of: " ", with: "-")
    }

    /// Renders a title with an italic brand mark when the string ends in `!`.
    @MainActor
    static func titleText(_ fullTitle: String) -> Text {
        if fullTitle.hasSuffix("!") {
            return Text {
                Span(String(fullTitle.dropLast()))
                Emphasis("!")
            }
        }
        return Text(fullTitle)
    }

    /// Renders a linked title with an italic brand mark when the string ends in `!`.
    @MainActor
    static func linkedTitle(_ fullTitle: String, target: String) -> Text {
        if fullTitle.hasSuffix("!") {
            return Text {
                Link(target: target) {
                    Span(String(fullTitle.dropLast()))
                    Emphasis("!")
                }
            }
        }
        return Text {
            Link(fullTitle, target: target)
        }
    }

    /// Section heading for app pages, e.g. "Why Xarra!?"
    @MainActor
    static func whySectionTitle(for appTitle: String) -> Text {
        phrase(prefix: "Why ", brandTitle: appTitle, suffix: "?")
    }

    /// Renders inline content with an italic brand mark when the string ends in `!`.
    @MainActor
    static func inlineTitle(_ fullTitle: String) -> Span {
        if fullTitle.hasSuffix("!") {
            return Span {
                Span(String(fullTitle.dropLast()))
                Emphasis("!")
            }
        }
        return Span(fullTitle)
    }

    /// Renders a linked inline title with an italic brand mark when the string ends in `!`.
    @MainActor
    static func linkedInlineTitle(_ fullTitle: String, target: String) -> Link {
        if fullTitle.hasSuffix("!") {
            return Link(target: target) {
                Span(String(fullTitle.dropLast()))
                Emphasis("!")
            }
        }
        return Link(fullTitle, target: target)
    }

    /// Mid-sentence UI copy with a branded app name, e.g. prefix "Rate ", suffix "" → "Rate Xarra!".
    @MainActor
    static func phrase(prefix: String, brandTitle: String, suffix: String = "") -> Text {
        Text {
            Span("\(prefix)\(baseName(brandTitle))")
            Emphasis("!")
            if !suffix.isEmpty {
                Span(suffix)
            }
        }
    }

    /// Inline variant of `phrase(prefix:brandTitle:suffix:)`.
    @MainActor
    static func inlinePhrase(prefix: String, brandTitle: String, suffix: String = "") -> Span {
        Span {
            Span("\(prefix)\(baseName(brandTitle))")
            Emphasis("!")
            if !suffix.isEmpty {
                Span(suffix)
            }
        }
    }

}