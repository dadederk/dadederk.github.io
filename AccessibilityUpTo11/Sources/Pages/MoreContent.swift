import Foundation
import Ignite

struct MoreContent: StaticPage {
    var title = "More Content"
    var path = "/more-content"
    
    @MainActor var body: some HTML {
        VStack(alignment: .leading) {
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


