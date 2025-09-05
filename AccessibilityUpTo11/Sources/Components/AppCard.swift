import Foundation
import Ignite

// Specialized card component for displaying app information
struct AppCard: HTML {
    let title: String
    let subtitle: String
    let description: String
    let nameOrigin: String
    let imagePath: String
    let imageDescription: String
    let actions: [ActionButton]
    
    var body: some HTML {
        Card {
            HStack {
                VStack(alignment: .leading) {
                    HStack(alignment: .center) {
                        Image(imagePath, description: imageDescription)
                            .resizable()
                            .aspectRatio(.square, contentMode: .fit)
                            .frame(width: 120, height: 120)
                            .padding()
                        
                        VStack(alignment: .leading) {
                            Text(title)
                                .font(.title3)
                                .fontWeight(.bold)
                                .horizontalAlignment(.leading)
                            
                            Text(subtitle)
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .padding(.bottom, 5)
                        }
                    }
                    
                    Text(description)
                        .font(.body)
                        .padding(.vertical)
                    
                    Text(nameOrigin)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .padding(.bottom)
                    
                    HStack {
                        ForEach(actions) { action in
                            action
                        }
                    }
                    .padding(.top)
                }
            }
        }
        .padding()
    }
}
