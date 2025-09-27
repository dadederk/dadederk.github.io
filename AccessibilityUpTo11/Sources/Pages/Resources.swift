import Foundation
import Ignite

struct Resources: StaticPage {
    var title = "Resources"
    
    @MainActor var body: some HTML {
        VStack(alignment: .leading) {
            // Page heading - proper H1
            Text("Resources")
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
                    Section {
                        // Section heading - proper H2
                        Text(section.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .horizontalAlignment(.leading)
                            .padding(.bottom)
                        
                        ForEach(section.subsections) { subsection in
                            VStack(alignment: .leading, spacing: 12) {
                                // Subsection heading - proper H3
                                Text(subsection.title)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .horizontalAlignment(.leading)
                                    .padding(.bottom, 4)
                                
                                // Resources list
                                List(subsection.items) { item in
                                    MarkdownRenderer(content: item.markdownText)
                                }
                            }
                            .padding(.bottom)
                        }
                    }
                    .padding(.bottom)
                }
            }
        }
    }
}

