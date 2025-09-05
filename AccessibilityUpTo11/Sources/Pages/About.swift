import Foundation
import Ignite

struct About: StaticPage {
    var title = "About"
    
    @MainActor var body: some HTML {
        VStack {
            
            // Author information
            Section {
                // Responsive layout: HStack for large viewports, VStack for small
                Group {
                    // Desktop/tablet layout (horizontal)
                    HStack(alignment: .center) {
                        AuthorInfoPanel()
                        Spacer()
                        SocialLinksPanel()
                    }
                    .class("d-none", "d-md-flex") // Hide on mobile, show on md and up
                    
                    // Mobile layout (vertical)
                    VStack(alignment: .center) {
                        AuthorInfoPanel()
                        SocialLinksPanel()
                    }
                    .class("d-md-none") // Show only on mobile
                }
                
                VStack(spacing: 6) {
                    // Author photo
                    Image("/Images/Site/Global/dani.jpg", description: "Daniel Devesa Derksen-Staats - iOS Developer & Accessibility Advocate")
                        .resizable()
                        .cornerRadius(6)
                        .border(.darkGray)
                    
                    // Author details
                    VStack(alignment: .leading) {
                        Text("""
                            Dani is having a blast working at Yoto! He has his dream job as an iOS engineer specialised in accessibility.
                            """)
                            .font(.body)
                            .padding(.bottom)
                        
                        Text("""
                            He's loved working at Spotify, Skyscanner, and the BBC, where he gained valuable experience making iOS apps more inclusive and fostering organisational cultures that prioritise accessibility.
                            """)
                            .font(.body)
                            .padding(.bottom)
                        
                        Text("""
                            Sometimes, he lets Xcode take a break and shares his passion for accessibility at conferences.
                            """)
                            .font(.body)
                            .padding(.bottom)
                        
                        Text("""
                            He is the author of the book "Developing Accessible iOS Apps", and likes to keep himself busy by writing iOS and accessibility tips on social media with the hashtag #365DaysIOSAccessibility.
                            """)
                            .font(.body)
                            .padding(.bottom)
                    }
                }
                .padding(.vertical)
            }
        }

    }
}


