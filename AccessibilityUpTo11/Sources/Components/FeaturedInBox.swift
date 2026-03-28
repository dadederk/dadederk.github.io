import Foundation
import Ignite

struct FeaturedInBox: HTML {
    let title: String
    let mentions: [FeaturedMention]
    let quotes: [FeaturedQuoteItem]

    init(
        title: String,
        mentions: [FeaturedMention],
        quote: String? = nil,
        quoteSourceTitle: String? = nil,
        quoteSourceTarget: String? = nil,
        quotes: [FeaturedQuoteItem] = []
    ) {
        self.title = title
        self.mentions = mentions
        
        var resolvedQuotes = quotes
        if let quote {
            resolvedQuotes.append(
                FeaturedQuoteItem(
                    text: quote,
                    sourceTitle: quoteSourceTitle,
                    sourceTarget: quoteSourceTarget
                )
            )
        }
        self.quotes = resolvedQuotes
    }

    @MainActor var body: some HTML {
        let visibleMentions = mentionsToRender()

        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.body)
                .fontWeight(.semibold)
                .horizontalAlignment(.leading)
                .style(.color, "var(--bs-primary)")

            if !visibleMentions.isEmpty {
                ForEach(visibleMentions) { mention in
                    Link(mention.title, target: mention.target)
                        .style(.textDecoration, "underline")
                        .style(.color, "var(--bs-primary)")
                }
            }

            if !quotes.isEmpty {
                ForEach(quotes) { quote in
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\"\(quote.text)\"")
                            .font(.body)
                            .horizontalAlignment(.leading)
                            .style(.color, "var(--bs-primary)")

                        if let sourceTitle = quote.sourceTitle {
                            if let sourceTarget = quote.sourceTarget {
                                Link("- \(sourceTitle)", target: sourceTarget)
                                    .font(.body)
                                    .style(.textDecoration, "underline")
                                    .horizontalAlignment(.leading)
                                    .style(.color, "var(--bs-primary)")
                            } else {
                                Text("- \(sourceTitle)")
                                    .font(.body)
                                    .horizontalAlignment(.leading)
                                    .style(.color, "var(--bs-primary)")
                            }
                        }
                    }
                    .padding(.top, 8)
                }
            }
        }
        .padding()
        .style(.width, "100%")
        .style(.backgroundColor, "var(--bs-navbar-bg)")
        .style(.border, "1px solid var(--bs-border-color)")
        .cornerRadius(8)
        .class("feature-panel")
    }

    private func mentionsToRender() -> [FeaturedMention] {
        let quotedTargets = Set(quotes.compactMap(\.sourceTarget))
        if quotedTargets.isEmpty {
            return mentions
        }
        return mentions.filter { !quotedTargets.contains($0.target) }
    }
}
