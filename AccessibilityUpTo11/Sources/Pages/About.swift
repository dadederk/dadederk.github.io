import Foundation
import Ignite

struct About: StaticPage {
    var title = "About"
    var description = "Meet Dani Devesa Derksen-Staats and explore publications, talks, and podcasts focused on accessible iOS development."
    var image: URL? { SiteMeta.imageURL("/Images/Site/Global/dani.jpg") }
    
    @MainActor var body: some HTML {
        VStack(alignment: .leading) {
            // Page heading - proper H1
            Text {
                Span("About ")
                Span("Accessibility up to 11")
                Emphasis("!")
            }
                .font(.title1)
                .fontWeight(.bold)
                .horizontalAlignment(.leading)
                .padding(.bottom, 10)
            
            // Author information
            Section {
                Grid(alignment: .topLeading) {
                    AuthorInfoPanel()
                        .width(6)
                    SocialLinksPanel()
                        .width(6)
                }
                
                VStack(spacing: 6) {
                    // Author photo
                    Image("/Images/Site/Global/dani.jpg", description: "Dani, smiling slightly while wearing a navy sweater and a flat cap, standing outdoors with the rolling green hills of Tuscany and a cloudy sky in the background.")
                        .resizable()
                        .cornerRadius(6)
                        .border(.darkGray)
                    
                    // Author details
                    VStack(alignment: .leading) {
                        Text("""
                            Dani is an iOS engineer and accessibility specialist from Xàbia, in the Marina Alta region of the Valencian Community, Spain, and is based in London. He's having a blast working at Yoto!
                            """)
                            .font(.body)
                            .padding(.vertical)
                        
                        Text("""
                            He's loved working at Apple (Contractor), Spotify, Skyscanner, and the BBC, where he gained valuable experience making iOS apps more inclusive and fostering organisational cultures that prioritise accessibility.
                            """)
                            .font(.body)
                            .padding(.bottom)
                        
                        Text("""
                            Sometimes, he lets Xcode take a break and shares his passion for accessibility at conferences.
                            """)
                            .font(.body)
                            .padding(.bottom)
                        
                        Text("""
                            He is the author of the book "Developing Accessible iOS Apps", and likes to keep himself busy by writing iOS and accessibility tips on social media with the hashtag #365DaysIOSAccessibility.
                            """)
                            .font(.body)
                            .padding(.bottom)
                    }
                }
                .padding(.vertical)
            }
            
            Divider()
            
            // Publications Section
            Section {
                let contentData = MoreContentData.loadContent()
                sectionHeading(
                    "Publications",
                    seeAll: contentData.publications.count > MoreContentData.aboutSectionLimit
                        ? "/about/publications" : nil
                )
                let publications = contentData.publications.prefix(MoreContentData.aboutSectionLimit)
                Grid(alignment: .topLeading) {
                    ForEach(publications) { publication in
                        ContentCard(publication: publication)
                            .width(4)
                    }
                }

                PublicationFeaturedSection()
            }
            .id("publications")
            .padding(.vertical)

            Divider()
            
            // Talks Section
            Section {
                let contentData = MoreContentData.loadContent()
                sectionHeading(
                    "Talks",
                    seeAll: contentData.talks.count > MoreContentData.aboutSectionLimit
                        ? "/about/talks" : nil
                )
                let talks = contentData.talks.prefix(MoreContentData.aboutSectionLimit)
                Grid(alignment: .topLeading) {
                    ForEach(talks) { talk in
                        ContentCard(talk: talk)
                            .width(4)
                    }
                }
            }
            .id("talks")
            .padding(.vertical)
            
            Divider()
            
            // Podcasts Section
            Section {
                let contentData = MoreContentData.loadContent()
                sectionHeading(
                    "Podcasts",
                    seeAll: contentData.podcasts.count > MoreContentData.aboutSectionLimit
                        ? "/about/podcasts" : nil
                )
                let podcasts = contentData.podcasts.prefix(MoreContentData.aboutSectionLimit)
                Grid(alignment: .topLeading) {
                    ForEach(podcasts) { podcast in
                        ContentCard(podcast: podcast)
                            .width(4)
                    }
                }
            }
            .id("podcasts")
            .padding(.vertical)
        }
    }

    @MainActor private func sectionHeading(_ title: String, seeAll target: String?) -> some HTML {
        HStack(alignment: .bottom) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .horizontalAlignment(.leading)
            if let target {
                Link("See All", target: target)
                    .font(.body)
            }
        }
        .style(.flexWrap, "wrap")
        .style(.gap, "0.5rem")
        .padding(.bottom)
    }
}
