import Foundation
import Ignite

struct Resources: StaticPage {
    var title = "Resources"
    
    @MainActor var body: some HTML {
        VStack(alignment: .leading) {
            // Page heading - proper H1
            Text("I've Found All These Resources Incredibly Useful")
                .font(.title1)
                .fontWeight(.bold)
                .horizontalAlignment(.leading)
                .padding(.bottom)
            
            // Description
            Text("A curated collection of accessibility resources, books, articles, talks, and more to help you build inclusive mobile applications.")
                .font(.body)
                .horizontalAlignment(.leading)
                .padding(.bottom)
            
            // Main resources content with proper semantic structure
            let resourcesData = ResourcesData.loadContent()
            
            Section {
                ForEach(resourcesData.sections) { section in
                    ResourceSection(section: section)
                }
            }
        }
    }
}

