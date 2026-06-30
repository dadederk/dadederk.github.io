import Foundation
import Ignite

struct SupportWorkBox: HTML {
    @MainActor var body: some HTML {
        VStack(alignment: .leading, spacing: 8) {
            Text("Some of you have asked me how you can support what I do. This would really help, and would be hugely appreciated:")
                .font(.body)
                .fontWeight(.semibold)
                .horizontalAlignment(.leading)
                .foregroundStyle(.primary)

            List {
                ListItem {
                    Text("Find these posts useful? Share them at work, on social media, or with anyone that might find them interesting. Let's spread the word!")
                        .font(.body)
                        .horizontalAlignment(.leading)
                        .foregroundStyle(.primary)
                }

                ListItem {
                    VStack(alignment: .leading, spacing: 6) {
                        Text {
                            Span("Check out any of my apps or games: ")
                            BrandCopy.linkedInlineTitle("Xarra!", target: "/apps/xarra")
                            Span(", ")
                            BrandCopy.linkedInlineTitle("RetroRapid!", target: "/apps/retrorapid")
                            Span(", or ")
                            BrandCopy.linkedInlineTitle("Mestre!", target: "/apps/mestre")
                            Span(".")
                        }
                        .font(.body)
                        .horizontalAlignment(.leading)
                        .foregroundStyle(.primary)

                        List {
                            ListItem {
                                Text("A download and a review go a long way. They're free by default. On the App Store, ratings and reviews really help more people discover them.")
                                    .font(.body)
                                    .horizontalAlignment(.leading)
                                    .foregroundStyle(.primary)
                            }

                            ListItem {
                                Text("Finding any of them useful? If so, and if you can afford it, purchasing lifetime access to all features or subscribing lets me buy the coffee that keeps me caffeinated. Caffeine keeps me going to maintain the apps, bring in new features that I hope you'll love, and keep writing.")
                                    .font(.body)
                                    .horizontalAlignment(.leading)
                                    .foregroundStyle(.primary)
                            }
                        }
                    }
                }
            }
            .font(.body)
            .foregroundStyle(.primary)
        }
        .padding()
        .style(.width, "100%")
        .style(.backgroundColor, "var(--bs-secondary-bg)")
        .style(.border, "1px solid var(--bs-border-color)")
        .cornerRadius(8)
    }
}
