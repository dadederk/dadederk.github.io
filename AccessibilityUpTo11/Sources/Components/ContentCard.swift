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
    
    var body: some HTML {
        Card {
            if let imagePath = imagePath, let imageDescription = imageDescription {
                // Original horizontal layout for cards with images (publications)
                HStack {
                    VStack(alignment: .leading) {
                        Text(title)
                            .font(.title3)
                            .fontWeight(.bold)
                            .horizontalAlignment(.leading)
                        
                        if let subtitle = subtitle {
                            Text(subtitle)
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .padding(.bottom, 5)
                        }
                        
                        VStack(alignment: .center) {
                            Image(imagePath, description: imageDescription)
                                .resizable()
                                .aspectRatio(.square, contentMode: .fill)
                                .frame(width: 200, height: 200)
                                .border(.gray)
                                .cornerRadius(6)
                        }
                        .padding(.top)
                        
                        Text(description)
                            .font(.body)
                            .padding(.vertical)
                        
                        if let additionalInfo = additionalInfo {
                            Text(additionalInfo)
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }
                        
                        HStack {
                            ForEach(actions) { action in
                                action
                            }
                        }
                        .padding(.top)
                    }
                }
            } else {
                // Vertical layout for cards without images (talks, podcasts)
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.title4)
                        .fontWeight(.bold)
                        .horizontalAlignment(.leading)
                    
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
                            .padding(.bottom)
                    }
                    
                    VStack(alignment: .center) {
                        ForEach(actions) { action in
                            action
                        }
                    }
                }
            }
        }
        .padding()
    }
}
