import Foundation
import Ignite

// Extracted component for social links panel
struct SocialLinksPanel: HTML {
    var body: some HTML {
        HStack(alignment: .center) {
            VStack {
                Text("Let's connect!")
                    .font(.body)
                    .fontWeight(.semibold)
                    .horizontalAlignment(.center)

                // Desktop layout: horizontal
                HStack {
                    Link("Twitter", target: "https://twitter.com/dadederk")
                    Link("Mastodon", target: "https://iosdev.space/@dadederk")
                    Link("BlueSky", target: "https://bsky.app/profile/dadederk.bsky.social")
                    Link("LinkedIn", target: "https://linkedin.com/in/danieldevesaderksenstaats")
                    Link("GitHub", target: "https://github.com/dadederk")
                }
                .horizontalAlignment(.center)
                .class("d-none", "d-lg-flex") // Hide on mobile/tablet, show on large screens

                // Mobile layout: 3x3 grid
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        Link("Twitter", target: "https://twitter.com/dadederk")
                            .frame(minWidth: 80)
                        Link("Mastodon", target: "https://iosdev.space/@dadederk")
                            .frame(minWidth: 80)
                        Link("BlueSky", target: "https://bsky.app/profile/dadederk.bsky.social")
                            .frame(minWidth: 80)
                    }
                    HStack(spacing: 8) {
                        Link("LinkedIn", target: "https://linkedin.com/in/danieldevesaderksenstaats")
                            .frame(minWidth: 80)
                        Link("GitHub", target: "https://github.com/dadederk")
                            .frame(minWidth: 80)
                    }
                }
                .class("d-lg-none") // Show on mobile/tablet, hide on large screens
            }
            .padding()
        }
        .background(.antiqueWhite)
        .border(.darkGray)
        .cornerRadius(8)

    }
}
