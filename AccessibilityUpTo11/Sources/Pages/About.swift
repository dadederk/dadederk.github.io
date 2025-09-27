import Foundation
import Ignite

struct About: StaticPage {
    var title = "About"
    
    @MainActor var body: some HTML {
        VStack(alignment: .leading) {
            // Page heading
            Text("About Accessibility up to 11!")
                .font(.title1)
                .fontWeight(.bold)
                .horizontalAlignment(.leading)
                .padding(.bottom)
            
            // Author information
            Section {
                // Responsive layout: HStack for large viewports, VStack for small
                Group {
                    // Desktop/tablet layout (horizontal)
                    HStack(alignment: .center) {
                        AuthorInfoPanel()
                        Spacer()
                        SocialLinksPanel()
                    }
                    .class("d-none", "d-md-flex") // Hide on mobile, show on md and up
                    
                    // Mobile layout (vertical)
                    VStack(alignment: .center) {
                        AuthorInfoPanel()
                        SocialLinksPanel()
                    }
                    .class("d-md-none") // Show only on mobile
                }
                
                VStack(spacing: 6) {
                    // Author photo
                    Image("/Images/Site/Global/dani.jpg", description: "Daniel Devesa Derksen-Staats - iOS Developer & Accessibility Advocate")
                        .resizable()
                        .cornerRadius(6)
                        .border(.darkGray)
                    
                    // Author details
                    VStack(alignment: .leading) {
                        Text("""
                            Dani is having a blast working at Yoto! He has his dream job as an iOS engineer specialised in accessibility.
                            """)
                            .font(.body)
                            .padding(.bottom)
                        
                        Text("""
                            He's loved working at Spotify, Skyscanner, and the BBC, where he gained valuable experience making iOS apps more inclusive and fostering organisational cultures that prioritise accessibility.
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


