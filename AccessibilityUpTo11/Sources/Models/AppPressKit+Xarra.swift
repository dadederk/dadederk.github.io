extension AppPressKit {
    static let xarra = AppPressKit(
        appSlug: "xarra",
        tagline: "Xarra turns text into audio with synchronized line highlighting, so people can read, listen, or do both.",
        productURL: "https://accessibilityupto11.com/apps/xarra/",
        storeURL: "https://apps.apple.com/us/app/xarra/id6759402266",
        headerIconPath: "/Images/Site/Apps/Xarra/Press/xarra-icon-1024.png",
        archive: AppPressDownload(
            title: "Download press kit (ZIP)",
            path: "/Downloads/xarra-press-kit.zip",
            filename: "xarra-press-kit.zip"
        ),
        actions: [
            AppPressAction(title: "Resumen en español", target: "#resumen-es")
        ],
        facts: [
            AppPressFact("Price", "Free download. Premium: US $1.99/month, $9.99/year, or $29.99 lifetime. Regional pricing aims to reflect local purchasing power."),
            AppPressFact("Platforms", "iPhone — including iPhone Duo — iPad, Mac, and Apple Vision Pro; OS version 26.0 or later on each platform"),
            AppPressFact("Availability", "Available now on the App Store; first released March 2026"),
            AppPressFact("Developer", "Dani Devesa Derksen-Staats, independent developer behind Accessibility up to 11!, from Xàbia and based in London"),
            AppPressFact(
                "Website",
                value: AppPressParagraph(fragments: [
                    .link(title: "https://accessibilityupto11.com/apps/xarra/", target: "https://accessibilityupto11.com/apps/xarra/")
                ])
            ),
            AppPressFact(
                "App Store",
                value: AppPressParagraph(fragments: [
                    .link(title: "https://apps.apple.com/us/app/xarra/id6759402266", target: "https://apps.apple.com/us/app/xarra/id6759402266")
                ])
            ),
            AppPressFact("Privacy", "No account, ads, analytics, or tracking. Documents stay on device and can sync through the user's private iCloud account."),
            AppPressFact(
                "Giving back",
                value: AppPressParagraph(fragments: [
                    .text("10% of subscription proceeds are donated to "),
                    .link(title: "AMMEC", target: "https://www.ammec.org/"),
                    .text(", a Valencia-based nonprofit supporting people with physical disabilities and their families.")
                ])
            )
        ],
        recognitionTitle: "Awards & coverage",
        recognitionBanner: XarraRecognition.bannerImage,
        about: AppPressAbout(
            oneSentence: AppPressParagraph("Xarra turns articles, books, and documents into audio while highlighting the text in sync, so people can read, listen, or do both."),
            inBrief: [
                AppPressParagraph("Import an article, PDF, EPUB, Markdown file, DAISY text publication, URL, or your own writing. Read on screen, listen with Apple voices, or combine both. Xarra highlights the current line as it reads; spoken words can also be underlined or highlighted with a background, or left unmarked. Chapters and iCloud progress sync help you pick up where you left off. Xarra adapts to iPhone Duo and, on supported systems, integrates library discovery and playback with Siri, Spotlight, and Shortcuts.")
            ],
            storyLead: "Dani, in his own words:",
            story: [
                AppPressParagraph("I built Xarra because I was finding it harder to get through long pieces of text, especially on a screen. Listening while reading helped me stay with it; seeing the current line and each spoken word highlighted helped even more. I read more, understand better, and go back less often — and I can keep going on a walk or while doing chores. Xarra grew out of wanting one place to read, listen, or do both, without losing my place."),
                AppPressParagraph("From the start, accessibility and a native Apple experience were at the heart of it: meet people where they are, rather than asking them to adapt. I hope it helps more people get through their reading in whatever way works for them.")
            ]
        ),
        demoVideo: AppPressVideo(
            title: "Demo video",
            description: "A one-minute overview of Xarra.",
            youTubeID: "-fBbvx9dTus",
            watchURL: "https://youtu.be/-fBbvx9dTus"
        ),
        features: [
            AppPressFeature(title: "Import content", description: "Import PDF, EPUB, Markdown, DAISY, plain text, and other documents; share from another app, paste text, add a URL, or browse Project Gutenberg."),
            AppPressFeature(title: "Follow the text", description: "Synchronized line highlighting keeps audio and text together. Spoken words can be underlined, highlighted with a background, or left unmarked."),
            AppPressFeature(title: "Made for Apple devices", description: "A native experience on iPhone — including iPhone Duo — iPad, Mac, and Apple Vision Pro, with an interface designed for each device and available space."),
            AppPressFeature(title: "Find and start faster", description: "On supported systems, search the Xarra library with Siri, discover documents in Spotlight, or use Shortcuts to resume, play, or open a document."),
            AppPressFeature(title: "Continue across devices", description: "Your library and listening position can sync through your private iCloud account."),
            AppPressFeature(title: "Lightweight and private", description: "A small app download using Apple's on-device voices. No Xarra account, ads, analytics, or trackers; downloaded content works offline."),
            AppPressFeature(title: "Accessible interaction", description: "Supports VoiceOver, Voice Control, Switch Control, Full Keyboard Access, Dynamic Type (including all larger accessibility text sizes), and other system accessibility settings."),
            AppPressFeature(title: "Smarter listening", description: "On supported devices, Apple Intelligence can summarise content, suggest tags and categories, and turn code blocks into natural, audio-friendly explanations.")
        ],
        screenshots: AppPressMediaSection(
            title: "Screenshots",
            intro: [
                AppPressParagraph(fragments: [
                    .text("Screenshots, photos, icons, and artwork may be used for editorial coverage of Xarra. Please credit Xarra / Dani Devesa Derksen-Staats for the photos, screenshots, and Xarra artwork, GAAD Foundation for the Gaadys mark, and "),
                    .link(title: "Raúl Gil", target: "https://raul-gil.com/"),
                    .text(" for the app icon. Full-resolution files are in the "),
                    .link(title: "downloadable press kit", target: "/Downloads/xarra-press-kit.zip"),
                    .text(".")
                ])
            ],
            root: "/Images/Site/Apps/Xarra/Press/",
            kind: "screenshot",
            items: [
                AppPressMedia(filename: "iphone-reading.png", title: "Read and listen", details: "iPhone · 1206 × 2622 px", alt: "Xarra on iPhone reading a welcome document with the current line highlighted and playback controls below."),
                AppPressMedia(filename: "iphone-word-highlighting.png", title: "Word highlighting", details: "iPhone · 1206 × 2622 px", alt: "Xarra on iPhone in Dark Mode with synchronized line and word highlighting during playback."),
                AppPressMedia(filename: "iphone-share-import.png", title: "Share into Xarra", details: "iPhone · 1206 × 2622 px", alt: "Xarra's share extension on iPhone confirming content is ready to finish importing in the app."),
                AppPressMedia(filename: "ipad-import-sources.png", title: "Import sources", details: "iPad · 2752 × 2064 px", alt: "Xarra on iPad with the Add menu open beside a readable document, showing text, URL, document, and Gutenberg import options."),
                AppPressMedia(filename: "ipad-accessibility.png", title: "Larger text and VoiceOver", details: "iPad · 2752 × 2064 px", alt: "Xarra on iPad with enlarged document text and a visible VoiceOver focus outline."),
                AppPressMedia(filename: "mac-voices.png", title: "Voice preferences", details: "Mac · 2160 × 1456 px", alt: "Xarra on Mac showing voice settings and preferred voices for several languages."),
                AppPressMedia(filename: "mac-audio-friendly-code.png", title: "Code made listenable", details: "Mac · 2160 × 1456 px", alt: "Xarra on Mac showing an edit window with a Swift code block and a plain-language audio explanation."),
                AppPressMedia(filename: "vision-reading-room.jpeg", title: "Spatial reading", details: "Apple Vision Pro · 3840 × 2160 px", alt: "Xarra's reading window on Apple Vision Pro in a room, with a library sidebar, transcript, and playback controls."),
                AppPressMedia(filename: "vision-focus-mode.jpeg", title: "Focus Mode", details: "Apple Vision Pro · 3840 × 2160 px", alt: "Xarra on Apple Vision Pro in Focus Mode, showing one enlarged line with the current word highlighted and playback controls below.")
            ],
            columnWidth: 4
        ),
        icons: AppPressIconSection(
            intro: [
                AppPressParagraph(fragments: [
                    .text("Designed by illustrator "),
                    .link(title: "Raúl Gil", target: "https://raul-gil.com/"),
                    .text(".")
                ])
            ],
            downloads: [
                AppPressDownload(title: "Download 1024 × 1024 PNG", path: "/Images/Site/Apps/Xarra/Press/xarra-icon-1024.png", filename: "xarra-icon-1024.png"),
                AppPressDownload(title: "Download 512 × 512 PNG", path: "/Images/Site/Apps/Xarra/Press/xarra-icon-512.png", filename: "xarra-icon-512.png"),
                AppPressDownload(title: "Download 256 × 256 PNG", path: "/Images/Site/Apps/Xarra/Press/xarra-icon-256.png", filename: "xarra-icon-256.png")
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
            photo: AppPressPhoto(
                path: "/Images/Site/Apps/Xarra/Press/dani-with-xarra-hammersmith-bridge.jpg",
                fullResolutionPath: "/Images/Site/Apps/Xarra/Press/dani-with-xarra-hammersmith-bridge-full-resolution.jpg",
                filename: "dani-with-xarra-hammersmith-bridge-full-resolution.jpg",
                alt: "Dani smiling while holding an iPhone showing Xarra, with Hammersmith Bridge behind him.",
                caption: "Dani with Xarra near Hammersmith Bridge, London."
            )
        ),
        additionalMediaSections: [
            AppPressMediaSection(
                title: "Product photos",
                intro: [AppPressParagraph("Photographs by Dani Devesa Derksen-Staats on the Thames Path in Hammersmith, London.")],
                root: "/Images/Site/Apps/Xarra/Press/",
                kind: "photo",
                items: [
                    AppPressMedia(filename: "xarra-thames-path-wide.jpg", title: "Listening on the Thames Path", details: nil, alt: "A hand holds an iPhone displaying Xarra's reader beside the River Thames, with the riverbank and path behind it."),
                    AppPressMedia(filename: "xarra-thames-path-dark-mode.jpg", title: "Reading in Dark Mode", details: nil, alt: "A hand holds an iPhone showing Xarra's reader in Dark Mode, with a highlighted word and playback controls open."),
                    AppPressMedia(filename: "xarra-thames-path-airpods.jpg", title: "Xarra and AirPods", details: nil, alt: "An iPhone displaying Xarra's reader lies beside an orange AirPods case on stone paving.")
                ],
                columnWidth: 4
            ),
            AppPressMediaSection(
                title: "Xarra! artwork",
                intro: [],
                root: "/Images/Site/Apps/Xarra/Press/",
                kind: "artwork",
                items: [
                    AppPressMedia(filename: "xarra-2-0-app-store-event-card.png", title: "Library and reader", details: nil, alt: "Composite artwork showing an iPhone with Xarra's library in Dark Mode and another with the reader in light mode, against curved blue, cream, coral, and navy shapes."),
                    AppPressMedia(filename: "xarra-gaady-award-2026-card.png", title: "2026 Gaady Award winner", details: nil, alt: "Xarra's library and reader on two iPhones beside a badge reading '2026', the official Gaadys logo, 'Winner', and 'Xarra', against flowing blue, cream, coral, and navy bands.")
                ],
                columnWidth: 6
            )
        ],
        localizedSummary: AppPressLocalizedSummary(
            id: "resumen-es",
            title: "Resumen para medios en español",
            language: "es",
            paragraphs: [
                AppPressParagraph("Xarra es una app para iPhone, iPad, Mac y Apple Vision Pro creada por Dani Devesa Derksen-Staats, desarrollador independiente de Xàbia afincado en Londres. Su nombre viene de una palabra valenciana/catalana que significa «charlar» o «hablar». Convierte texto en audio, desde artículos y entradas de blog hasta libros y documentos.", language: "es"),
                AppPressParagraph("Puedes leer, escuchar o combinar ambas cosas, con resaltado sincronizado de líneas y, si lo prefieres, de palabras para seguir mejor el texto. Permite importar PDF, EPUB, Markdown, publicaciones DAISY, enlaces y texto; navegar por capítulos; y continuar en otros dispositivos mediante iCloud.", language: "es"),
                AppPressParagraph("En iPhone Duo, la interfaz se adapta al espacio disponible. En sistemas compatibles, también puedes buscar en tu biblioteca con Siri, encontrar documentos con Spotlight y usar Atajos para reanudar, reproducir o abrir una lectura.", language: "es"),
                AppPressParagraph(fragments: [
                    .text("Está disponible en el App Store y se puede descargar gratis, con opciones Premium. El 10% de los ingresos de las suscripciones se dona a "),
                    .link(title: "AMMEC", target: "https://www.ammec.org/"),
                    .text(", una asociación valenciana que apoya a personas con discapacidades físicas y a sus familias.")
                ], language: "es"),
                AppPressParagraph(fragments: [
                    .text("En 2026, Xarra fue una de las cinco ganadoras de los "),
                    .link(title: "Premios Gaady", target: "https://gaad.foundation/what-we-do/gaadys/winners/xarra"),
                    .text(" de la GAAD Foundation.")
                ], language: "es"),
                AppPressParagraph(fragments: [
                    .text("Para entrevistas o materiales de prensa: "),
                    .link(title: "hello@accessibilityUpTo11.com", target: "mailto:hello@accessibilityUpTo11.com"),
                    .text(".")
                ], language: "es")
            ],
            links: [
                AppPressAction(title: "Ver la demostración de Xarra en español", target: "https://www.youtube.com/watch?v=0BES0gr123I")
            ]
        )
    )
}
