extension AppPressKit {
    static let retroRapid = AppPressKit(
        appSlug: "retrorapid",
        tagline: "A three-lane retro arcade racer built for quick score chases, live SharePlay friend races, and accessible play.",
        productURL: "https://accessibilityupto11.com/apps/retrorapid/",
        storeURL: "https://apps.apple.com/app/id6758641625",
        headerIconPath: "/Images/Site/Apps/RetroRapid/Press/retrorapid-icon-1024.png",
        archive: AppPressDownload(
            title: "Download press kit (ZIP)",
            path: "/Downloads/retrorapid-press-kit.zip",
            filename: "retrorapid-press-kit.zip"
        ),
        actions: [],
        facts: [
            AppPressFact("Price", "Free download. Nine solo plays on the first day, then three per day. Unlimited Plays: US $2.99 one-time purchase; regional pricing varies. No subscription. SharePlay friend races and Apple Watch play are always free."),
            AppPressFact("Platforms", "iPhone — including iPhone Duo — iPad, Mac, and Apple Watch; OS version 26.0 or later on each platform"),
            AppPressFact("Availability", "Available now on the App Store; first released February 2026"),
            AppPressFact("Developer", "Dani Devesa Derksen-Staats, independent developer behind Accessibility up to 11!, from Xàbia and based in London"),
            AppPressFact(
                "Website",
                value: AppPressParagraph(fragments: [
                    .link(title: "https://accessibilityupto11.com/apps/retrorapid/", target: "https://accessibilityupto11.com/apps/retrorapid/")
                ])
            ),
            AppPressFact(
                "App Store",
                value: AppPressParagraph(fragments: [
                    .link(title: "https://apps.apple.com/app/id6758641625", target: "https://apps.apple.com/app/id6758641625")
                ])
            ),
            AppPressFact("Privacy", "No data collection, ads, analytics, or tracking. Solo racing works offline."),
            AppPressFact(
                "Giving back",
                value: AppPressParagraph(fragments: [
                    .text("10% of proceeds are donated to "),
                    .link(title: "AMMEC", target: "https://ammec.org/"),
                    .text(", a Valencia-based nonprofit supporting people with physical disabilities and their families.")
                ])
            )
        ],
        recognitionTitle: "Coverage",
        recognitionBanner: nil,
        about: AppPressAbout(
            oneSentence: AppPressParagraph("RetroRapid! is a fast three-lane arcade racer where players dodge traffic, chase high scores, and race friends live with SharePlay."),
            inBrief: [
                AppPressParagraph("Steer left or right, weave through traffic, and keep going as the road gets faster. Every overtake adds to the score, and three lives stand between a new run and a new record."),
                AppPressParagraph("Play solo on iPhone, iPad, Mac, or Apple Watch, or start a live two-player SharePlay race on iPhone, iPad, or Mac. Both players face the same traffic and can follow each other's score and remaining lives before jumping into a rematch.")
            ],
            storyLead: nil,
            story: [
                AppPressParagraph("RetroRapid! spent more than seven years in a drawer. From the beginning, the goals were to build a game that worked on Apple Watch and make it as accessible as possible. It was unexpectedly released from the ARCtic conference in Oulu, Finland, after attendees played it and encouraged Dani to ship it."),
                AppPressParagraph("Since release, the original left-or-right score chase has added Game Center leaderboards and achievements, live SharePlay races, more control methods, and additional accessibility options.")
            ]
        ),
        demoVideo: nil,
        features: [
            AppPressFeature(title: "Core gameplay", description: "Three-lane endless racing with left-or-right steering, three lives, increasing speed, score tracking, and immediate restarts."),
            AppPressFeature(title: "SharePlay multiplayer", description: "Real-time two-player races on iPhone, iPad, and Mac. Both players receive the same traffic sequence and can see the other player's score, remaining lives, and avatar during the race."),
            AppPressFeature(title: "Game Center", description: "Leaderboards, 22 achievements, and in-road markers showing friends' best scores."),
            AppPressFeature(title: "Platform-specific controls", description: "Tap and swipe controls on iPhone and iPad, keyboard input on Mac, the Digital Crown on Apple Watch, supported game controllers, and an iPhone Duo tabletop layout."),
            AppPressFeature(title: "Accessibility", description: "VoiceOver with Direct Touch, configurable audio cues and haptics, Larger Text, high contrast, Reduce Motion, Big Cars, and adjustable road feedback."),
            AppPressFeature(title: "Local-first design", description: "Solo racing works offline without an account. Game Center and SharePlay are optional system integrations; the app has no ads, analytics, or trackers.")
        ],
        screenshots: AppPressMediaSection(
            title: "Screenshots",
            intro: [
                AppPressParagraph(fragments: [
                    .text("Screenshots, app icons, and artwork may be used for editorial coverage of RetroRapid. Please credit RetroRapid / Dani Devesa Derksen-Staats. Full-resolution files are in the "),
                    .link(title: "downloadable press kit", target: "/Downloads/retrorapid-press-kit.zip"),
                    .text(".")
                ])
            ],
            root: "/Images/Site/Apps/RetroRapid/Press/",
            kind: "screenshot",
            items: [
                AppPressMedia(filename: "iphone-gameplay-classic.jpeg", title: "Classic racing", details: "iPhone · 1320 × 2868 px", alt: "RetroRapid gameplay on iPhone in the Classic style, with a player car approaching traffic on a cream three-lane road and red controls below."),
                AppPressMedia(filename: "iphone-accessibility-settings.jpeg", title: "Accessibility settings", details: "iPhone · 1320 × 2868 px", alt: "RetroRapid settings on iPhone showing audio feedback, speed warning feedback, Detailed Road, Big Cars, and Direct Touch options."),
                AppPressMedia(filename: "iphone-shareplay.jpeg", title: "Live friend race", details: "iPhone · 1320 × 2868 px", alt: "RetroRapid gameplay on iPhone during a SharePlay friend race, with the friend's avatar pinned over their car."),
                AppPressMedia(filename: "iphone-pocket-style.jpeg", title: "Pocket style", details: "iPhone · 1320 × 2868 px", alt: "RetroRapid gameplay on iPhone in the green monochrome Pocket style."),
                AppPressMedia(filename: "iphone-voiceover-achievement.jpeg", title: "VoiceOver achievement", details: "iPhone · 1320 × 2868 px", alt: "RetroRapid on iPhone showing the VoiceOver Controls Game Center achievement after a completed run."),
                AppPressMedia(filename: "ipad-friend-score-marker.jpeg", title: "Friend score marker", details: "iPad · 5504 × 4128 px", alt: "RetroRapid gameplay on iPad with a Game Center friend marker floating beside traffic on the road."),
                AppPressMedia(filename: "mac-best-score.png", title: "Best-score chase", details: "Mac · 2024 × 1672 px", alt: "RetroRapid on Mac showing a completed run, new record, and the next friend's score over the racing screen."),
                AppPressMedia(filename: "mac-crt-style.png", title: "CRT style on Mac", details: "Mac · 2024 × 1672 px", alt: "RetroRapid gameplay on Mac using the platform-default CRT style, with a crashed car beside the road and a Speed increasing banner."),
                AppPressMedia(filename: "apple-watch-gameplay.jpeg", title: "Race on Apple Watch", details: "Apple Watch · 422 × 514 px", alt: "RetroRapid gameplay on Apple Watch in the green Pocket style, with score, lives, pause, and close controls around the road.")
            ],
            columnWidth: 4
        ),
        icons: AppPressIconSection(
            intro: [
                AppPressParagraph("The Classic icon pairs RetroRapid's pink brand colour with the game's monochrome pixel racer.")
            ],
            downloads: [
                AppPressDownload(title: "Download 1024 × 1024 PNG", path: "/Images/Site/Apps/RetroRapid/Press/retrorapid-icon-1024.png", filename: "retrorapid-icon-1024.png"),
                AppPressDownload(title: "Download 512 × 512 PNG", path: "/Images/Site/Apps/RetroRapid/Press/retrorapid-icon-512.png", filename: "retrorapid-icon-512.png"),
                AppPressDownload(title: "Download 256 × 256 PNG", path: "/Images/Site/Apps/RetroRapid/Press/retrorapid-icon-256.png", filename: "retrorapid-icon-256.png")
            ]
        ),
        developer: AppPressDeveloper(
            bio: [
                AppPressParagraph("Dani Devesa Derksen-Staats is an accessibility specialist and independent developer from Xàbia in the Marina Alta region of the Valencian Community, Spain, and is based in London. He currently works at Yoto and has previously worked at Apple (as a contractor), Spotify, and the BBC. He writes Accessibility up to 11! and is the author of the book Developing Accessible iOS Apps.")
            ],
            linksTitle: "More information",
            links: [
                AppPressAction(title: "More about Dani", target: "/about/"),
                AppPressAction(title: "Developing Accessible iOS Apps (book)", target: "https://www.springerprofessional.de/en/developing-accessible-ios-apps/17490934"),
                AppPressAction(title: "Watch the Double Tap interview", target: "https://www.youtube.com/watch?v=3JMD70vf2yY")
            ],
            contactTitle: "Press contact",
            photo: nil
        ),
        additionalMediaSections: [
            AppPressMediaSection(
                title: "RetroRapid! artwork",
                intro: [
                    AppPressParagraph("Pixel-art illustrations created for RetroRapid! 2.0's approved App Store in-app event. These are promotional artworks, not gameplay screenshots.")
                ],
                root: "/Images/Site/Apps/RetroRapid/Press/",
                kind: "artwork",
                items: [
                    AppPressMedia(filename: "shareplay-event-card.png", title: "SharePlay event card", details: "App Store in-app event · 1920 × 1080 px", alt: "Pixel artwork of two retro racing cars side by side on a road at sunset."),
                    AppPressMedia(filename: "shareplay-event-details.png", title: "SharePlay event details", details: "App Store in-app event · 1080 × 1920 px", alt: "Portrait pixel artwork of two retro racing cars side by side beneath a glowing sunset.")
                ],
                columnWidth: 6
            )
        ],
        localizedSummary: nil
    )
}
