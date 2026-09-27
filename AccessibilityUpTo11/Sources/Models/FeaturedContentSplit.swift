import Foundation

struct FeaturedFeatureGroup {
    let mentions: [FeaturedMention]
    let quotes: [FeaturedQuoteItem]

    var isEmpty: Bool {
        mentions.isEmpty && quotes.isEmpty
    }
}

/// Splits features so the introduction stays short.
///
/// Quotes come before link-only mentions. Within each group, the incoming
/// order is the priority order. When there are more than two features, the
/// first two stay with the page heading and the rest use
/// ``additionalHeading``.
struct FeaturedContentSplit {
    static let additionalHeading = "Also featured in..."

    let primary: FeaturedFeatureGroup
    let additional: FeaturedFeatureGroup

    static func split(
        mentions: [FeaturedMention],
        quotes: [FeaturedQuoteItem]
    ) -> FeaturedContentSplit {
        let quotedTargets = Set(quotes.compactMap(\.sourceTarget))
        var ordered: [(mention: FeaturedMention?, quote: FeaturedQuoteItem?)] = quotes.map { (nil, $0) }
        for mention in mentions where !quotedTargets.contains(mention.target) {
            ordered.append((mention, nil))
        }

        let primaryItems: ArraySlice<(mention: FeaturedMention?, quote: FeaturedQuoteItem?)>
        let additionalItems: ArraySlice<(mention: FeaturedMention?, quote: FeaturedQuoteItem?)>
        if ordered.count > 2 {
            primaryItems = ordered.prefix(2)
            additionalItems = ordered.dropFirst(2)
        } else {
            primaryItems = ordered[...]
            additionalItems = []
        }

        return FeaturedContentSplit(
            primary: group(primaryItems),
            additional: group(additionalItems)
        )
    }

    private static func group(
        _ items: ArraySlice<(mention: FeaturedMention?, quote: FeaturedQuoteItem?)>
    ) -> FeaturedFeatureGroup {
        FeaturedFeatureGroup(
            mentions: items.compactMap(\.mention),
            quotes: items.compactMap(\.quote)
        )
    }
}
