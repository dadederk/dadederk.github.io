import Foundation

/// Curated 365 Days topic titles for H1, cards, and SEO.
enum RecommendedTitlesLoader {
    static func title(for dayNumber: Int) -> String? {
        RecommendedTitles.byDay[dayNumber]
    }
}
