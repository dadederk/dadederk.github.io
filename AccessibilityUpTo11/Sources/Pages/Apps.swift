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
            
            let appsData = AppsData.loadContent()
            
            // Apps section
            let apps = appsData.apps.filter { $0.category == .app }
            if !apps.isEmpty {
                Section {
                    Text("Apps")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.bottom, .small)
                    
                    Grid(alignment: .topLeading) {
                        ForEach(apps) { app in
                            AppCard(
                                title: app.title,
                                subtitle: app.subtitle,
                                description: app.description,
                                nameOrigin: app.nameOrigin,
                                imagePath: app.imagePath,
                                imageDescription: app.imageDescription,
                                platforms: app.platforms,
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
            
            // Sticker Packs section
            let stickerPacks = appsData.apps.filter { $0.category == .stickerPack }
            if !stickerPacks.isEmpty {
                Section {
                    Text("Sticker Packs")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.bottom, .small)
                    
                    Grid(alignment: .topLeading) {
                        ForEach(stickerPacks) { app in
                            AppCard(
                                title: app.title,
                                subtitle: app.subtitle,
                                description: app.description,
                                nameOrigin: app.nameOrigin,
                                imagePath: app.imagePath,
                                imageDescription: app.imageDescription,
                                platforms: app.platforms,
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
            
            // Games section
            let games = appsData.apps.filter { $0.category == .game }
            if !games.isEmpty {
                Section {
                    Text("Games")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.bottom, .small)
                    
                    Grid(alignment: .topLeading) {
                        ForEach(games) { app in
                            AppCard(
                                title: app.title,
                                subtitle: app.subtitle,
                                description: app.description,
                                nameOrigin: app.nameOrigin,
                                imagePath: app.imagePath,
                                imageDescription: app.imageDescription,
                                platforms: app.platforms,
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
}
