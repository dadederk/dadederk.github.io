import Foundation
import Ignite

// Generic AppPage template that can be reused for any app
struct AppPage: StaticPage {
    let appIdentifier: String
    let appTitle: String
    let appPath: String
    
    init(appIdentifier: String, appTitle: String, appPath: String) {
        self.appIdentifier = appIdentifier
        self.appTitle = appTitle
        self.appPath = appPath
    }
    
    var title: String { appTitle }
    var path: String { appPath }
    
    @MainActor var body: some HTML {
        VStack(alignment: .leading) {
            if let app = findApp() {
                // Header section with app info
                Section {
                    VStack(alignment: .leading) {
                        HStack(alignment: .top) {
                            Image(app.imagePath, description: app.imageDescription)
                                .resizable()
                                .aspectRatio(.square, contentMode: .fit)
                                .frame(width: 100, height: 100)
                                .padding()
                            
                            VStack(alignment: .leading) {
                                Text(app.title)
                                    .font(.title1)
                                    .fontWeight(.bold)
                                    .horizontalAlignment(.leading)
                                
                                Text(app.subtitle)
                                    .font(.title2)
                                    .foregroundStyle(.secondary)
                                    .padding(.bottom, 10)
                            }
                        }
                        .padding(.bottom)
                        
                        Text(app.description)
                            .font(.body)
                            .padding(.bottom, 10)
                        
                        Text(app.nameOrigin)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .padding(.bottom, 20)
                        
                        // Action buttons
                        HStack {
                            ForEach(app.actions) { action in
                                ActionButton(
                                    title: action.title,
                                    target: action.target,
                                    style: action.style == "primary" ? .primary : .secondary
                                )
                            }
                        }
                        .padding(.bottom, 20)
                        
                        // Terms, Privacy, and Support links
                        HStack {
                            Link("Terms & Conditions", target: "\(appPath)/terms")
                                .class("btn btn-outline-secondary")
                            
                            Link("Privacy Policy", target: "\(appPath)/privacy")
                                .class("btn btn-outline-secondary")
                            
                            Link("Support & Contact", target: "#support-contact")
                                .class("btn btn-outline-secondary")
                        }
                    }
                    .class("d-none d-md-flex") // Show HStack on medium+ screens
                    
                    // Mobile layout - VStack
                    VStack(alignment: .leading) {
                        Image(app.imagePath, description: app.imageDescription)
                            .resizable()
                            .aspectRatio(.square, contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .padding()
                        
                        VStack(alignment: .leading) {
                            Text(app.title)
                                .font(.title1)
                                .fontWeight(.bold)
                            
                            Text(app.subtitle)
                                .font(.title2)
                                .foregroundStyle(.secondary)
                                .padding(.bottom, 10)
                            
                            Text(app.description)
                                .font(.body)
                                .padding(.bottom, 10)
                            
                            Text(app.nameOrigin)
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .padding(.bottom, 20)
                            
                            // Action buttons
                            HStack {
                                ForEach(app.actions) { action in
                                    ActionButton(
                                        title: action.title,
                                        target: action.target,
                                        style: action.style == "primary" ? .primary : .secondary
                                    )
                                }
                            }
                            .padding(.bottom, 20)
                            
                            // Terms, Privacy, and Support links
                            VStack(alignment: .leading) {
                                Link("Terms & Conditions", target: "\(appPath)/terms")
                                    .class("btn btn-outline-secondary mb-2")
                                
                                Link("Privacy Policy", target: "\(appPath)/privacy")
                                    .class("btn btn-outline-secondary mb-2")
                                
                                Link("Support & Contact", target: "#support-contact")
                                    .class("btn btn-outline-secondary")
                            }
                        }
                    }
                    .class("d-md-none") // Show VStack on small screens only
                }
                .padding(.vertical)
                
                // Features section with grid
                Section {
                    Text("Features")
                        .font(.title2)
                        .fontWeight(.bold)
                        .horizontalAlignment(.leading)
                        .padding(.bottom)
                    
                    Grid(alignment: .topLeading) {
                        ForEach(app.features) { feature in
                            Card {
                                VStack(alignment: .leading) {
                                    if let imagePath = feature.imagePath {
                                        Image(imagePath, description: feature.imageDescription ?? "Feature screenshot")
                                            .resizable()
                                            .aspectRatio(.square, contentMode: .fit)
                                            .frame(height: 150)
                                            .padding(.bottom)
                                    }
                                    
                                    Text(feature.title)
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .padding(.bottom, 5)
                                    
                                    Text(feature.description)
                                        .font(.body)
                                }
                            }
                            .width(4)
                        }
                    }
                }
                .padding(.vertical)
                
                // Support & Contact section
                Section {
                    Text("Support & Contact")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.bottom)
                        .horizontalAlignment(.leading)
                    
                    Text(app.supportText)
                        .font(.body)
                        .padding(.bottom)
                        .horizontalAlignment(.leading)
                    
                    HStack {
                        Link("Contact", target: "mailto:\(app.contactEmail)")
                            .horizontalAlignment(.leading)
                            .class("btn btn-primary")
                    }
                }
                .id("support-contact")
                .padding(.vertical)
            } else {
                // App not found
                Section {
                    Text("App not found")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical)
            }
        }
    }
    
    private func findApp() -> AppItem? {
        let appsData = AppsData.loadContent()
        return appsData.apps.first { app in
            app.title.lowercased() == appIdentifier.lowercased()
        }
    }
}
