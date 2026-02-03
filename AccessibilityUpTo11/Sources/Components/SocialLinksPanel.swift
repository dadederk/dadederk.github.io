import Foundation
import Ignite

// Extracted component for social links panel
struct SocialLinksPanel: HTML {
    @MainActor var body: some HTML {
        HStack(alignment: .center) {
            VStack {
                Text("Let's connect!")
                    .font(.body)
                    .fontWeight(.semibold)
                    .horizontalAlignment(.center)

                HStack(alignment: .center) {
                    socialLinks
                }
                .style(.flexWrap, "wrap")
                .style(.gap, "0.5rem")
            }
            .padding()
        }
        .background(.antiqueWhite)
        .border(.darkGray)
        .cornerRadius(8)

    }
    
    @MainActor private var socialLinks: some HTML {
        Group {
            Link("Twitter", target: "https://twitter.com/dadederk")
            Link("Mastodon", target: "https://iosdev.space/@dadederk")
            Link("BlueSky", target: "https://bsky.app/profile/dadederk.bsky.social")
            Link("LinkedIn", target: "https://www.linkedin.com/in/danieldevesa/")
            Link("GitHub", target: "https://github.com/dadederk")
        }
    }
}
