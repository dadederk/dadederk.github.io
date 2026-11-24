import Ignite

/// Introduces Dani's community initiatives and their editorial coverage.
struct CommunityProjectsSection: HTML {
    @MainActor var body: some HTML {
        Section {
            Text("Community projects")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.bottom)

            Text {
                Link("Sponsored by Indies", target: "https://sponsored.byindies.com/")
            }
            .font(.title3)
            .fontWeight(.semibold)

            Text("""
                Dani started Sponsored by Indies to help support community conferences by bringing indie creators together. Apps, games, books, and tools are offered free or at a discount as part of conference ticket bundles, giving attendees extra value and helping people discover independent projects.
                """)
                .font(.body)

            FeaturedInBox(
                title: "Sponsored by Indies featured in",
                mentions: [],
                quote: "built on the brilliant idea of bundling conference tickets with indie products to make them more valuable for attendees.",
                quoteSourceTitle: "Alex Ozun, iOS Dev Weekly #777 · 20 November 2026",
                quoteSourceTarget: "https://iosdevweekly.com/issues/777/"
            )
        }
        .id("community-projects")
        .padding(.vertical)
    }
}
