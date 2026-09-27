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
        let sharedSubject = sharedSubjectTitle

        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.body)
                .fontWeight(.semibold)
                .horizontalAlignment(.leading)
                .foregroundStyle(.primary)

            if let sharedSubject {
                subjectLabel(sharedSubject.text, target: sharedSubject.target)
            }

            if !quotes.isEmpty || !visibleMentions.isEmpty {
                List {
                    ForEach(quotes) { quote in
                        ListItem {
                            VStack(alignment: .leading, spacing: 4) {
                                if sharedSubject == nil, shouldShowSubject(for: quote), let subject = quote.subject {
                                    subjectLabel(subject, target: quote.subjectTarget)
                                }

                                Text("\"\(quote.text)\"")
                                    .font(.body)
                                    .horizontalAlignment(.leading)
                                    .foregroundStyle(.primary)

                                if let sourceTitle = quote.sourceTitle {
                                    if let sourceTarget = quote.sourceTarget {
                                        Link("- \(sourceTitle)", target: sourceTarget)
                                            .font(.body)
                                            .horizontalAlignment(.leading)
                                            .foregroundStyle(.primary)
                                    } else {
                                        Text("- \(sourceTitle)")
                                            .font(.body)
                                            .horizontalAlignment(.leading)
                                            .foregroundStyle(.primary)
                                    }
                                }
                            }
                        }
                    }

                    ForEach(visibleMentions) { mention in
                        ListItem {
                            Link(mention.title, target: mention.target)
                                .foregroundStyle(.primary)
                        }
                    }
                }
                .margin(.bottom, .none)
            }
        }
        .padding()
        .style(.width, "100%")
        .style(.backgroundColor, "var(--bs-secondary-bg)")
        .style(.border, "1px solid var(--bs-border-color)")
        .cornerRadius(8)
    }

    private var sharedSubjectTitle: (text: String, target: String?)? {
        guard let subject = quotes.first?.subject,
              quotes.allSatisfy({ $0.subject == subject && $0.subjectTarget == quotes.first?.subjectTarget }) else {
            return nil
        }
        return (subject, quotes.first?.subjectTarget)
    }

    @HTMLBuilder @MainActor private func subjectLabel(_ subject: String, target: String?) -> some HTML {
        if let target {
            Link(subject, target: target)
                .font(.body)
                .fontWeight(.semibold)
                .horizontalAlignment(.leading)
                .foregroundStyle(.primary)
        } else {
            Text(subject)
                .font(.body)
                .fontWeight(.semibold)
                .horizontalAlignment(.leading)
                .foregroundStyle(.primary)
        }
    }

    private func shouldShowSubject(for quote: FeaturedQuoteItem) -> Bool {
        guard quote.subject != nil,
              let index = quotes.firstIndex(where: { $0.id == quote.id }) else {
            return false
        }
        if index == 0 {
            return true
        }
        return quotes[index - 1].subject != quote.subject
    }

    private func mentionsToRender() -> [FeaturedMention] {
        let quotedTargets = Set(quotes.compactMap(\.sourceTarget))
        if quotedTargets.isEmpty {
            return mentions
        }
        return mentions.filter { !quotedTargets.contains($0.target) }
    }
}
