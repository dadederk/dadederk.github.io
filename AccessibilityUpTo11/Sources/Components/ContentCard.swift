import Foundation
import Ignite

// Unified content card that can handle both horizontal (with image) and vertical layouts
struct ContentCard: HTML {
    let title: String
    let subtitle: String?
    let description: String
    let additionalInfo: String?
    let imagePath: String?
    let imageDescription: String?
    let actions: [ActionButton]
    
    // Convenience initializer for cards without images (talks, podcasts)
    init(title: String, subtitle: String?, description: String, additionalInfo: String? = nil, actions: [ActionButton]) {
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.additionalInfo = additionalInfo
        self.imagePath = nil
        self.imageDescription = nil
        self.actions = actions
    }
    
    // Full initializer for cards with images (publications)
    init(title: String, subtitle: String?, description: String, additionalInfo: String? = nil, imagePath: String, imageDescription: String, actions: [ActionButton]) {
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.additionalInfo = additionalInfo
        self.imagePath = imagePath
        self.imageDescription = imageDescription
        self.actions = actions
    }
    
    @MainActor var body: some HTML {
        if let imagePath = imagePath, let _ = imageDescription {
            // Horizontal layout for cards with images (publications)
            Card(imageName: imagePath) {
                VStack(alignment: .leading) {
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .padding(.bottom, 5)
                    }
                    
                    Text(description)
                        .font(.body)
                        .padding(.bottom)
                    
                    if let additionalInfo = additionalInfo {
                        Text(additionalInfo)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                }
            } header: {
                Text(title)
                    .font(.title2)
                    .foregroundStyle(.body)
            } footer: {
                HStack(alignment: .center) {
                    ForEach(actions) { action in
                        action
                            .padding(.top, 4)
                    }
                }
                .style(.display, "flex")
                .style(.flexWrap, "wrap")
                .margin(.top, -5)
            }
        } else {
            // Vertical layout for cards without images (talks, podcasts)
            Card {
                VStack(alignment: .leading) {
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .padding(.bottom, 5)
                    }
                    
                    Text(description)
                        .font(.body)
                        .padding(.bottom)
                    
                    if let additionalInfo = additionalInfo {
                        Text(additionalInfo)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                }
            } header: {
                Text(title)
                    .font(.title2)
                    .foregroundStyle(.body)
            } footer: {
                HStack(alignment: .center) {
                    ForEach(actions) { action in
                        action
                            .padding(.top, 4)
                    }
                }
                .style(.display, "flex")
                .style(.flexWrap, "wrap")
                .margin(.top, -5)
            }
        }
    }
}
