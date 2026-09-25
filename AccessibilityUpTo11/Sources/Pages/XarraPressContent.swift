import Ignite

struct XarraPressContent: HTML {
    let app: AppItem

    private let productURL = "https://accessibilityupto11.com/apps/xarra/"
    private let storeURL = "https://apps.apple.com/us/app/xarra/id6759402266"
    private let mediaRoot = "/Images/Site/Apps/Xarra/Press/"

    private var contactEmail: String { app.contactEmail }

    @MainActor var body: some HTML {
        VStack(alignment: .leading) {
            Section {
                Image("\(mediaRoot)xarra-icon-1024.png", description: "Xarra app icon")
                    .resizable()
                    .frame(width: 96, height: 96)

                VStack(alignment: .leading) {
                    BrandCopy.phrase(prefix: "", brandTitle: app.title, suffix: " Press Kit")
                        .font(.title1)
                        .fontWeight(.bold)

                    Text("Xarra turns text into audio with synchronized line highlighting, so people can read, listen, or do both.")
                        .font(.body)
                }
            }
            .class("xarra-press-header")

            Section {
                Link("Download press kit (ZIP)", target: "/Downloads/xarra-press-kit.zip")
                    .linkStyle(.button)
                    .role(.primary)
                    .attribute("download", "xarra-press-kit.zip")
                Link("App Store", target: storeURL)
                Link("Product page", target: productURL)
                Link("Email Dani", target: "mailto:\(contactEmail)")
                Link("Resumen en español", target: "#resumen-es")
            }
            .class("xarra-press-actions")

            Section {
                Text("At a glance")
                    .font(.title2)
                    .fontWeight(.bold)

                Section {
                    fact("Price", "Free download. Premium: US $1.99/month, $9.99/year, or $29.99 lifetime. Regional pricing aims to reflect local purchasing power.")
                    fact("Platforms", "iPhone, iPad, Mac, and Apple Vision Pro; OS version 26.0 or later on each platform")
                    fact("Availability", "Available now on the App Store; first released March 2026")
                    fact("Developer", "Dani Devesa Derksen-Staats, independent developer behind Accessibility up to 11!, from Xàbia and based in London")
                    linkedFact("Website", productURL, productURL)
                    linkedFact("App Store", storeURL, storeURL)
                    fact("Privacy", "No account, ads, analytics, or tracking. Documents stay on device and can sync through the user's private iCloud account.")
                    Section {
                        Text("Giving back").class("xarra-press-fact-label")
                        Text {
                            Span("10% of subscription proceeds are donated to ")
                            Link("AMMEC", target: "https://www.ammec.org/")
                            Span(", a Valencia-based nonprofit supporting people with physical disabilities and their families.")
                        }
                    }
                    .class("xarra-press-fact")
                }
                .class("xarra-press-facts")
            }
            .class("xarra-press-section")

            if !app.featuredIn.isEmpty {
                Section {
                    FeaturedInBox(
                        title: "Featured in",
                        mentions: app.featuredIn,
                        quote: app.featuredQuote,
                        quoteSourceTitle: app.featuredQuoteSourceTitle,
                        quoteSourceTarget: app.featuredQuoteSourceTarget
                    )
                }
                .class("xarra-press-section")
            }

            Section {
                BrandCopy.phrase(prefix: "About ", brandTitle: app.title)
                    .font(.title2)
                    .fontWeight(.bold)

                Text(app.nameOrigin)
                    .foregroundStyle(.secondary)

                Text("One sentence")
                    .font(.title3)
                Text("Xarra turns articles, books, and documents into audio while highlighting the text in sync, so people can read, listen, or do both.")

                Text("In brief")
                    .font(.title3)
                Text("Import an article, PDF, EPUB, DAISY text publication, URL, or your own writing. Read on screen, listen with Apple voices, or combine both. Xarra highlights the current line as it reads; spoken words can also be underlined or highlighted with a background, or left unmarked. Chapters and iCloud progress sync help you pick up where you left off.")

                Text("The story")
                    .font(.title3)
                Text("Dani, in his own words:")
                    .fontWeight(.semibold)
                Text("I built Xarra because I was finding it harder to get through long pieces of text, especially on a screen. Listening while reading helped me stay with it; seeing the current line and each spoken word highlighted helped even more. I read more, understand better, and go back less often — and I can keep going on a walk or while doing chores. Xarra grew out of wanting one place to read, listen, or do both, without losing my place.")
                Text("From the start, accessibility and a native Apple experience were at the heart of it: meet people where they are, rather than asking them to adapt. I hope it helps more people get through their reading in whatever way works for them.")
            }
            .class("xarra-press-section")

            Section {
                Text("Demo video")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("A one-minute overview of Xarra.")
                    .foregroundStyle(.secondary)

                Embed(youTubeID: "-fBbvx9dTus", title: "Xarra demo: a one-minute overview of the app")
                    .aspectRatio(.r16x9)
                    .class("xarra-press-video")

                Link("Watch on YouTube", target: "https://youtu.be/-fBbvx9dTus")
            }
            .class("xarra-press-section", "xarra-press-demo")

            Section {
                Text("Key features")
                    .font(.title2)
                    .fontWeight(.bold)
                Section {
                    feature("Import content", "Import PDF, EPUB, Markdown, DAISY, plain text, and other documents; share from another app, paste text, add a URL, or browse Project Gutenberg.")
                    feature("Follow the text", "Synchronized line highlighting keeps audio and text together. Spoken words can be underlined, highlighted with a background, or left unmarked.")
                    feature("Made for Apple devices", "A native experience on iPhone, iPad, Mac, and Apple Vision Pro, with an interface designed for each device.")
                    feature("Continue across devices", "Your library and listening position can sync through your private iCloud account.")
                    feature("Lightweight and private", "A small app download using Apple's on-device voices. No Xarra account, ads, analytics, or trackers; downloaded content works offline.")
                    feature("Accessible interaction", "Supports VoiceOver, Voice Control, Switch Control, Full Keyboard Access, Dynamic Type (including all larger accessibility text sizes), and other system accessibility settings.")
                }
                .class("xarra-press-features")
            }
            .class("xarra-press-section")

            Section {
                Text("Screenshots")
                    .font(.title2)
                    .fontWeight(.bold)
                Text {
                    Span("Screenshots, photos, icons, and artwork may be used for editorial coverage of Xarra. Please credit Xarra / Dani Devesa Derksen-Staats for the photos, screenshots, and artwork, and ")
                    Link("Raúl Gil", target: "https://raul-gil.com/")
                    Span(" for the app icon. Full-resolution files are in the ")
                    Link("downloadable press kit", target: "/Downloads/xarra-press-kit.zip")
                    Span(".")
                }
                .foregroundStyle(.secondary)
                .class("xarra-press-usage")

                Section {
                    ForEach(XarraPressMedia.screenshots) { media in
                        mediaItem(media, kind: "screenshot")
                    }
                }
                .class("xarra-press-media-grid")
            }
            .class("xarra-press-section")

            Section {
                Text("App icon")
                    .font(.title2)
                    .fontWeight(.bold)
                Text {
                    Span("Designed by illustrator ")
                    Link("Raúl Gil", target: "https://raul-gil.com/")
                    Span(".")
                }
                Section {
                    iconLink(1024)
                    iconLink(512)
                    iconLink(256)
                }
                .class("xarra-press-icon-links")
            }
            .class("xarra-press-section")

            Section {
                Text("About the developer")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("Dani Devesa Derksen-Staats is an accessibility specialist and independent developer from Xàbia in the Marina Alta region of the Valencian Community, Spain, and is based in London. He currently works at Yoto and has previously worked at Apple (as a contractor), Spotify, and the BBC. He writes Accessibility up to 11! and is the author of the book Developing Accessible iOS Apps.")

                Text("More information")
                    .font(.title3)
                List {
                    ListItem {
                        Link("More about Dani", target: "/about/")
                    }
                    ListItem {
                        Link("Developing Accessible iOS Apps (book)", target: "https://www.springerprofessional.de/en/developing-accessible-ios-apps/17490934")
                    }
                    ListItem {
                        Link("Watch the Double Tap interview", target: "https://www.youtube.com/watch?v=3JMD70vf2yY")
                    }
                }

                Text("Press contact")
                    .font(.title3)
                Link("Dani Devesa Derksen-Staats: \(contactEmail)", target: "mailto:\(contactEmail)")
            }
            .class("xarra-press-section")

            Section {
                Text("Product photos")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("Photographs by Dani Devesa Derksen-Staats on the Thames Path in Hammersmith, London.")
                    .foregroundStyle(.secondary)

                Section {
                    ForEach(XarraPressMedia.photos) { media in
                        mediaItem(media, kind: "photo")
                    }
                }
                .class("xarra-press-media-grid")
            }
            .class("xarra-press-section")

            Section {
                BrandCopy.phrase(prefix: "", brandTitle: app.title, suffix: " 2.0 artwork")
                    .font(.title2)
                    .fontWeight(.bold)

                Section {
                    mediaItem(XarraPressMedia.eventCard, kind: "artwork")
                }
                .class("xarra-press-media-grid")
            }
            .class("xarra-press-section")

            Section {
                Text("Resumen para medios en español")
                    .font(.title2)
                    .fontWeight(.bold)
                    .attribute("lang", "es")
                Text("Xarra es una app para iPhone, iPad, Mac y Apple Vision Pro creada por Dani Devesa Derksen-Staats, desarrollador independiente de Xàbia afincado en Londres. Su nombre viene de una palabra valenciana/catalana que significa «charlar» o «hablar». Convierte texto en audio, desde artículos y entradas de blog hasta libros y documentos. Puedes leer, escuchar o combinar ambas cosas, con resaltado sincronizado de líneas y, si lo prefieres, de palabras para seguir mejor el texto. Permite importar PDF, EPUB, publicaciones DAISY, enlaces y texto; navegar por capítulos; y continuar en otros dispositivos mediante iCloud. Está disponible en el App Store y se puede descargar gratis, con opciones Premium. El 10% de los ingresos de las suscripciones se dona a AMMEC, una asociación valenciana que apoya a personas con discapacidades físicas y a sus familias. Para entrevistas o materiales de prensa: \(contactEmail).")
                    .attribute("lang", "es")
            }
            .id("resumen-es")
            .class("xarra-press-section")
            .attribute("lang", "es")
        }
        .class("xarra-press")
    }

    @MainActor private func fact(_ label: String, _ value: String) -> some HTML {
        Section {
            Text(label).class("xarra-press-fact-label")
            Text(value)
        }
        .class("xarra-press-fact")
    }

    @MainActor private func linkedFact(_ label: String, _ text: String, _ target: String) -> some HTML {
        Section {
            Text(label).class("xarra-press-fact-label")
            Link(text, target: target)
        }
        .class("xarra-press-fact")
    }

    @MainActor private func feature(_ title: String, _ description: String) -> some HTML {
        Section {
            Text(title)
                .fontWeight(.semibold)
            Text(description)
        }
    }

    @MainActor private func iconLink(_ size: Int) -> some InlineElement {
        Link("Download \(size) × \(size) PNG", target: "\(mediaRoot)xarra-icon-\(size).png")
            .attribute("download", "xarra-icon-\(size).png")
    }

    @MainActor private func mediaItem(_ media: XarraPressMedia, kind: String) -> some HTML {
        Section {
            Link(target: mediaRoot + media.filename) {
                Image(mediaRoot + media.filename, description: media.alt)
                    .resizable()
            }
            .attribute("aria-label", "View full-size \(media.title) \(kind): \(media.alt)")
            Text(media.title)
                .font(.title3)
                .fontWeight(.semibold)
            if let details = media.details {
                Text(details)
                    .foregroundStyle(.secondary)
            }
            Link("Download original", target: mediaRoot + media.filename)
                .attribute("aria-label", "Download original: \(media.title) \(kind)")
                .attribute("download", media.filename)
        }
        .class("xarra-press-media")
    }
}

private struct XarraPressMedia: Identifiable {
    let filename: String
    let title: String
    let details: String?
    let alt: String

    var id: String { filename }

    static let photos: [Self] = [
        .init(filename: "xarra-thames-path-wide.jpg", title: "Listening on the Thames Path", details: nil, alt: "A hand holds an iPhone displaying Xarra's reader beside the River Thames, with the riverbank and path behind it."),
        .init(filename: "xarra-thames-path-dark-mode.jpg", title: "Reading in Dark Mode", details: nil, alt: "A hand holds an iPhone showing Xarra's reader in Dark Mode, with a highlighted word and playback controls open."),
        .init(filename: "xarra-thames-path-airpods.jpg", title: "Xarra and AirPods", details: nil, alt: "An iPhone displaying Xarra's reader lies beside an orange AirPods case on stone paving.")
    ]

    static let screenshots: [Self] = [
        .init(filename: "iphone-reading.png", title: "Read and listen", details: "iPhone · 1206 × 2622 px", alt: "Xarra on iPhone reading a welcome document with the current line highlighted and playback controls below."),
        .init(filename: "iphone-word-highlighting.png", title: "Word highlighting", details: "iPhone · 1206 × 2622 px", alt: "Xarra on iPhone in Dark Mode with synchronized line and word highlighting during playback."),
        .init(filename: "iphone-share-import.png", title: "Share into Xarra", details: "iPhone · 1206 × 2622 px", alt: "Xarra's share extension on iPhone confirming content is ready to finish importing in the app."),
        .init(filename: "ipad-import-sources.png", title: "Import sources", details: "iPad · 2752 × 2064 px", alt: "Xarra on iPad with the Add menu open beside a readable document, showing text, URL, document, and Gutenberg import options."),
        .init(filename: "ipad-accessibility.png", title: "Larger text and VoiceOver", details: "iPad · 2752 × 2064 px", alt: "Xarra on iPad with enlarged document text and a visible VoiceOver focus outline."),
        .init(filename: "mac-voices.png", title: "Voice preferences", details: "Mac · 2160 × 1456 px", alt: "Xarra on Mac showing voice settings and preferred voices for several languages."),
        .init(filename: "mac-audio-friendly-code.png", title: "Code made listenable", details: "Mac · 2160 × 1456 px", alt: "Xarra on Mac showing an edit window with a Swift code block and a plain-language audio explanation."),
        .init(filename: "vision-reading-room.jpeg", title: "Spatial reading", details: "Apple Vision Pro · 3840 × 2160 px", alt: "Xarra's reading window on Apple Vision Pro in a room, with a library sidebar, transcript, and playback controls."),
        .init(filename: "vision-focus-mode.jpeg", title: "Focus Mode", details: "Apple Vision Pro · 3840 × 2160 px", alt: "Xarra on Apple Vision Pro in Focus Mode, showing one enlarged line with the current word highlighted and playback controls below.")
    ]

    static let eventCard = Self(
        filename: "xarra-2-0-app-store-event-card.png",
        title: "Library and reader",
        details: nil,
        alt: "Composite artwork showing an iPhone with Xarra's library in Dark Mode and another with the reader in light mode, against curved blue, cream, coral, and navy shapes."
    )
}
