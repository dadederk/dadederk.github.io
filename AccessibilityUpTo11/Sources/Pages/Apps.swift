import Foundation
import Ignite

struct Apps: StaticPage {
    var title = "Apps"
    
    @MainActor var body: some HTML {
        VStack(alignment: .leading) {
            // Page heading
            Text("Our Apps")
                .font(.title1)
                .fontWeight(.bold)
                .horizontalAlignment(.leading)
                .padding(.bottom)
            
            // Apps content
            Section {
                let appsData = AppsData.loadContent()
                Grid(alignment: .topLeading) {
                    ForEach(appsData.apps) { app in
                        AppCard(
                            title: app.title,
                            subtitle: app.subtitle,
                            description: app.description,
                            nameOrigin: app.nameOrigin,
                            imagePath: app.imagePath,
                            imageDescription: app.imageDescription,
                            actions: app.actions.map { action in
                                ActionButton(
                                    title: action.title,
                                    target: action.target,
                                    style: action.style == "primary" ? .primary : .secondary
                                )
                            }
                        )
                        .width(6)
                    }
                }
            }
            .padding(.vertical)
        }
    }
}
