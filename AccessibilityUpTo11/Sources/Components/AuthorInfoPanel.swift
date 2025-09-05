import Foundation
import Ignite

// Extracted component for author information (name and title)
struct AuthorInfoPanel: HTML {
    @MainActor var body: some HTML {
        VStack(alignment: .leading) {
            Text("Daniel Devesa Derksen-Staats")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("iOS Developer & Accessibility Advocate")
                .font(.title2)
                .foregroundStyle(.secondary)
                .padding(.bottom)
        }
    }
}
