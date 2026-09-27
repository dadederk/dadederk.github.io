import Foundation
import Ignite

struct PublicationsPage: StaticPage {
    var title = "Publications"
    var path = "/about/publications"
    var description = "Books and articles by Dani Devesa Derksen-Staats on building accessible iOS apps."
    var image: URL? { SiteMeta.imageURL("/Images/Site/Global/dani.jpg") }

    @MainActor var body: some HTML {
        let publications = MoreContentData.loadContent().publications
        MoreContentCatalog(
            heading: title,
            intro: description,
            path: path,
            content: VStack(alignment: .leading) {
                Grid(alignment: .topLeading) {
                    ForEach(publications) { publication in
                        ContentCard(publication: publication)
                            .width(4)
                    }
                }
                PublicationFeaturedSection()
            }
        )
    }
}

struct TalksPage: StaticPage {
    var title = "Talks"
    var path = "/about/talks"
    var description = "Conference talks by Dani Devesa Derksen-Staats on iOS accessibility."
    var image: URL? { SiteMeta.imageURL("/Images/Site/Global/dani.jpg") }

    @MainActor var body: some HTML {
        let talks = MoreContentData.loadContent().talks
        MoreContentCatalog(
            heading: title,
            intro: description,
            path: path,
            content: Grid(alignment: .topLeading) {
                ForEach(talks) { talk in
                    ContentCard(talk: talk)
                        .width(4)
                }
            }
        )
    }
}

struct PodcastsPage: StaticPage {
    var title = "Podcasts"
    var path = "/about/podcasts"
    var description = "Podcast conversations with Dani Devesa Derksen-Staats about accessible iOS development."
    var image: URL? { SiteMeta.imageURL("/Images/Site/Global/dani.jpg") }

    @MainActor var body: some HTML {
        let podcasts = MoreContentData.loadContent().podcasts
        MoreContentCatalog(
            heading: title,
            intro: description,
            path: path,
            content: Grid(alignment: .topLeading) {
                ForEach(podcasts) { podcast in
                    ContentCard(podcast: podcast)
                        .width(4)
                }
            }
        )
    }
}

struct PublicationFeaturedSection: HTML {
    var body: some HTML {
        let publications = MoreContentData.loadContent().publications
        let quotes = publications.flatMap { publication in
            publication.featuredContent?.quotes.map { quote in
                FeaturedQuoteItem(
                    text: quote.text,
                    sourceTitle: quote.sourceTitle,
                    sourceTarget: quote.sourceTarget,
                    subject: publication.title,
                    subjectTarget: publication.actions.first { $0.style == "primary" }?.target
                        ?? publication.actions.first?.target
                )
            } ?? []
        }
        let mentions = publications.flatMap { publication in
            publication.featuredContent?.mentions ?? []
        }
        let split = FeaturedContentSplit.split(mentions: mentions, quotes: quotes)

        if !split.primary.isEmpty {
            FeaturedInBox(
                title: "Publications featured in",
                mentions: split.primary.mentions,
                quotes: split.primary.quotes
            )
            .padding(.top)
            .style(.width, "100%")
        }
        if !split.additional.isEmpty {
            FeaturedInBox(
                title: FeaturedContentSplit.additionalHeading,
                mentions: split.additional.mentions,
                quotes: split.additional.quotes
            )
            .padding(.top)
            .style(.width, "100%")
        }
    }
}

private struct MoreContentCatalog<Content: HTML>: HTML {
    let heading: String
    let intro: String
    let path: String
    let content: Content

    var body: some HTML {
        let breadcrumbData = BreadcrumbListStructuredData.json(
            crumbs: BreadcrumbListStructuredData.aboutSectionCrumbs(name: heading, path: path)
        )

        Script(code: breadcrumbData)
            .attribute("type", "application/ld+json")

        VStack(alignment: .leading) {
            Section {
                Link(target: "/about") {
                    Span("← Back to About")
                }
                .style(.textDecoration, "none")
                .foregroundStyle(.secondary)
                .horizontalAlignment(.leading)
            }
            .horizontalAlignment(.leading)
            .padding(.bottom)

            Text(heading)
                .font(.title1)
                .fontWeight(.bold)
                .horizontalAlignment(.leading)
                .padding(.bottom, 10)

            Text(intro)
                .font(.body)
                .horizontalAlignment(.leading)
                .padding(.bottom)

            content
        }
    }
}
