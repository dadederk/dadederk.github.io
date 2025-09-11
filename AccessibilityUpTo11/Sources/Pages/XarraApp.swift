import Foundation
import Ignite

struct XarraApp: StaticPage {
    var title = "Xarra"
    var path = "/apps/xarra"
    
    @MainActor var body: some HTML {
        VStack {
            if let app = findApp() {
                // Header section with app info
                Section {
                    HStack(alignment: .top) {
                        Image(app.imagePath, description: app.imageDescription)
                            .resizable()
                            .aspectRatio(.square, contentMode: .fit)
                            .frame(width: 200, height: 200)
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
                                Link("Terms & Conditions", target: "/apps/xarra/terms")
                                    .class("btn btn-outline-secondary")
                                
                                Link("Privacy Policy", target: "/apps/xarra/privacy")
                                    .class("btn btn-outline-secondary")
                                
                                Link("Support & Contact", target: "#support-contact")
                                    .class("btn btn-outline-secondary")
                            }
                        }
                    }
                    .class("d-none d-md-flex") // Show HStack on medium+ screens
                    
                    // Mobile layout - VStack
                    VStack(alignment: .leading) {
                        Image(app.imagePath, description: app.imageDescription)
                            .resizable()
                            .aspectRatio(.square, contentMode: .fit)
                            .frame(width: 200, height: 200)
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
                            VStack {
                                Link("Terms & Conditions", target: "/apps/xarra/terms")
                                    .class("btn btn-outline-secondary mb-2")
                                
                                Link("Privacy Policy", target: "/apps/xarra/privacy")
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
                        // Feature 1
                        Card {
                            VStack(alignment: .leading) {
                                Image(app.imagePath, description: "Feature screenshot")
                                    .resizable()
                                    .aspectRatio(.square, contentMode: .fit)
                                    .frame(height: 150)
                                    .padding(.bottom)
                                
                                Text("Feature 1")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .padding(.bottom, 5)
                                
                                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.")
                                    .font(.body)
                            }
                        }
                        .width(4)
                        
                        // Feature 2
                        Card {
                            VStack(alignment: .leading) {
                                Image(app.imagePath, description: "Feature screenshot")
                                    .resizable()
                                    .aspectRatio(.square, contentMode: .fit)
                                    .frame(height: 150)
                                    .padding(.bottom)
                                
                                Text("Feature 2")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .padding(.bottom, 5)
                                
                                Text("Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.")
                                    .font(.body)
                            }
                        }
                        .width(4)
                        
                        // Feature 3
                        Card {
                            VStack(alignment: .leading) {
                                Image(app.imagePath, description: "Feature screenshot")
                                    .resizable()
                                    .aspectRatio(.square, contentMode: .fit)
                                    .frame(height: 150)
                                    .padding(.bottom)
                                
                                Text("Feature 3")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .padding(.bottom, 5)
                                
                                Text("Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.")
                                    .font(.body)
                            }
                        }
                        .width(4)
                    }
                }
                .padding(.vertical)
                
                // Support & Contact section
                Section {
                    Text("Support & Contact")
                        .font(.title2)
                        .fontWeight(.bold)
                        .horizontalAlignment(.leading)
                        .padding(.bottom)
                    
                    Text("Need help or have questions about \(app.title)? We're here to assist you.")
                        .font(.body)
                        .padding(.bottom)
                    
                    HStack {
                        Link("Contact", target: "mailto:dadederk@icloud.com")
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
            app.title.lowercased() == "xarra"
        }
    }
}
