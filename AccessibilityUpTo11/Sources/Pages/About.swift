import Foundation
import Ignite

struct About: StaticPage {
    var title = "About"
    var description = "Meet Daniel Devesa Derksen-Staats and explore publications, talks, and podcasts focused on accessible iOS development."
    var image: URL? { SiteMeta.imageURL("/Images/Site/Global/dani.jpg") }
    
    @MainActor var body: some HTML {
        VStack(alignment: .leading) {
            // Page heading - proper H1
            Text("About Accessibility up to 11!")
                .font(.title1)
                .fontWeight(.bold)
                .horizontalAlignment(.leading)
                .padding(.bottom)
            
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
                    Image("/Images/Site/Global/dani.jpg", description: "Daniel, smiling slightly while wearing a navy sweater and a flat cap, standing outdoors with the rolling green hills of Tuscany and a cloudy sky in the background.")
                        .resizable()
                        .cornerRadius(6)
                        .border(.darkGray)
                    
                    // Author details
                    VStack(alignment: .leading) {
                        Text("""
                            Dani is having a blast working at Yoto!
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
                Text("Publications")
                    .font(.title2)
                    .fontWeight(.bold)
                    .horizontalAlignment(.leading)
                    .padding(.bottom)
                
                let contentData = MoreContentData.loadContent()
                Grid(alignment: .topLeading) {
                    ForEach(contentData.publications) { publication in
                        ContentCard(
                            title: publication.title,
                            subtitle: publication.subtitle,
                            description: publication.description,
                            additionalInfo: publication.publisher,
                            imagePath: publication.imagePath,
                            imageDescription: publication.imageDescription,
                            actions: publication.actions.map { action in
                                ActionButton(
                                    title: action.title,
                                    target: action.target,
                                    style: action.style == "primary" ? .primary : .secondary
                                )
                            }
                        )
                        .width(4)
                    }
                }
            }
            .id("publications")
            .padding(.vertical)

            Divider()
            
            // Talks Section
            Section {
                Text("Talks")
                    .font(.title2)
                    .fontWeight(.bold)
                    .horizontalAlignment(.leading)
                    .padding(.bottom)
                
                let contentData = MoreContentData.loadContent()
                Grid(alignment: .topLeading) {
                    ForEach(contentData.talks) { talk in
                        if let imagePath = talk.imagePath, let imageDescription = talk.imageDescription {
                            ContentCard(
                                title: talk.title,
                                subtitle: talk.subtitle,
                                description: talk.description,
                                imagePath: imagePath,
                                imageDescription: imageDescription,
                                actions: talk.actions.map { action in
                                    ActionButton(
                                        title: action.title,
                                        target: action.target,
                                        style: action.style == "primary" ? .primary : .secondary
                                    )
                                }
                            )
                            .width(4)
                        } else {
                            ContentCard(
                                title: talk.title,
                                subtitle: talk.subtitle,
                                description: talk.description,
                                actions: talk.actions.map { action in
                                    ActionButton(
                                        title: action.title,
                                        target: action.target,
                                        style: action.style == "primary" ? .primary : .secondary
                                    )
                                }
                            )
                            .width(4)
                        }
                    }
                }
            }
            .id("talks")
            .padding(.vertical)
            
            Divider()
            
            // Podcasts Section
            Section {
                Text("Podcasts")
                    .font(.title2)
                    .fontWeight(.bold)
                    .horizontalAlignment(.leading)
                    .padding(.bottom)
                
                let contentData = MoreContentData.loadContent()
                Grid(alignment: .topLeading) {
                    ForEach(contentData.podcasts) { podcast in
                        if let imagePath = podcast.imagePath, let imageDescription = podcast.imageDescription {
                            ContentCard(
                                title: podcast.title,
                                subtitle: podcast.subtitle,
                                description: podcast.description,
                                imagePath: imagePath,
                                imageDescription: imageDescription,
                                actions: podcast.actions.map { action in
                                    ActionButton(
                                        title: action.title,
                                        target: action.target,
                                        style: action.style == "primary" ? .primary : .secondary
                                    )
                                }
                            )
                            .width(4)
                        } else {
                            ContentCard(
                                title: podcast.title,
                                subtitle: podcast.subtitle,
                                description: podcast.description,
                                actions: podcast.actions.map { action in
                                    ActionButton(
                                        title: action.title,
                                        target: action.target,
                                        style: action.style == "primary" ? .primary : .secondary
                                    )
                                }
                            )
                            .width(4)
                        }
                    }
                }
            }
            .id("podcasts")
            .padding(.vertical)
        }
    }
}
