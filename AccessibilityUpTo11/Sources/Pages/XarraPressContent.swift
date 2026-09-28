import Ignite

struct XarraPressContent: HTML {
    let app: AppItem

    private let productURL = "https://accessibilityupto11.com/apps/xarra/"
    private let storeURL = "https://apps.apple.com/us/app/xarra/id6759402266"
    private let mediaRoot = "/Images/Site/Apps/Xarra/Press/"

    private var contactEmail: String { app.contactEmail }

    @MainActor var body: some HTML {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 20) {
                Image("\(mediaRoot)xarra-icon-1024.png", description: "Xarra app icon")
                    .resizable()
                    .frame(width: 96, height: 96)
                    .cornerRadius(20)

                VStack(alignment: .leading, spacing: 6) {
                    BrandCopy.phrase(prefix: "", brandTitle: app.title, suffix: " Press Kit")
                        .font(.title1)
                        .fontWeight(.bold)

                    Text("Xarra turns text into audio with synchronized line highlighting, so people can read, listen, or do both.")
                        .font(.body)
                }
                .style(.flex, "1 1 auto")
                .style(.minWidth, "0")
            }
            .style(.flexWrap, "wrap")
            .padding(.bottom, 20)

            HStack(alignment: .center, spacing: 12) {
                AppStoreDownloadBadge(target: storeURL)

                Link("Download press kit (ZIP)", target: "/Downloads/xarra-press-kit.zip")
                    .linkStyle(.button)
                    .role(.primary)
                    .attribute("download", "xarra-press-kit.zip")

                PillLink(title: "Product page", target: productURL)
                PillLink(title: "Email Dani", target: "mailto:\(contactEmail)")
                PillLink(title: "Resumen en español", target: "#resumen-es")
            }
            .class("action-row")
            .style(.flexWrap, "wrap")
            .padding()
            .frame(width: .percent(100%))
            .background("var(--bs-secondary-bg)")
            .style(.border, "1px solid var(--bs-border-color)")
            .cornerRadius(6)

            pressSection(divider: app.featuredIn.isEmpty) {
                Text("At a glance")
                    .font(.title2)
                    .fontWeight(.bold)

                Grid(alignment: .topLeading, spacing: 24) {
                    fact("Price", "Free download. Premium: US $1.99/month, $9.99/year, or $29.99 lifetime. Regional pricing aims to reflect local purchasing power.")
                        .width(6)
                    fact("Platforms", "iPhone, iPad, Mac, and Apple Vision Pro; OS version 26.0 or later on each platform")
                        .width(6)
                    fact("Availability", "Available now on the App Store; first released March 2026")
                        .width(6)
                    fact("Developer", "Dani Devesa Derksen-Staats, independent developer behind Accessibility up to 11!, from Xàbia and based in London")
                        .width(6)
                    linkedFact("Website", productURL, productURL)
                        .width(6)
                    linkedFact("App Store", storeURL, storeURL)
                        .width(6)
                    fact("Privacy", "No account, ads, analytics, or tracking. Documents stay on device and can sync through the user's private iCloud account.", divider: false)
                        .width(6)
                    fact("Giving back", divider: false, content: {
                        Text {
                            Span("10% of subscription proceeds are donated to ")
                            Link("AMMEC", target: "https://www.ammec.org/")
                            Span(", a Valencia-based nonprofit supporting people with physical disabilities and their families.")
                        }
                    })
                    .width(6)
                }
                .class("glance-facts")
                .frame(width: .percent(100%))
            }

            if !app.featuredIn.isEmpty {
                pressSection(divider: false) {
                    FeaturedInBox(
                        title: "Awards & coverage",
                        mentions: app.featuredIn,
                        quote: app.featuredQuote,
                        quoteSourceTitle: app.featuredQuoteSourceTitle,
                        quoteSourceTarget: app.featuredQuoteSourceTarget,
                        trailingImage: XarraRecognition.bannerImage
                    )
                }
            }

            pressSection {
                BrandCopy.phrase(prefix: "About ", brandTitle: app.title)
                    .font(.title2)
                    .fontWeight(.bold)

                Text(app.nameOrigin)
                    .foregroundStyle(.secondary)

                subsectionTitle("One sentence")
                Text("Xarra turns articles, books, and documents into audio while highlighting the text in sync, so people can read, listen, or do both.")

                subsectionTitle("In brief")
                Text("Import an article, PDF, EPUB, DAISY text publication, URL, or your own writing. Read on screen, listen with Apple voices, or combine both. Xarra highlights the current line as it reads; spoken words can also be underlined or highlighted with a background, or left unmarked. Chapters and iCloud progress sync help you pick up where you left off.")

                subsectionTitle("The story")
                Text("Dani, in his own words:")
                    .fontWeight(.semibold)
                Text("I built Xarra because I was finding it harder to get through long pieces of text, especially on a screen. Listening while reading helped me stay with it; seeing the current line and each spoken word highlighted helped even more. I read more, understand better, and go back less often — and I can keep going on a walk or while doing chores. Xarra grew out of wanting one place to read, listen, or do both, without losing my place.")
                Text("From the start, accessibility and a native Apple experience were at the heart of it: meet people where they are, rather than asking them to adapt. I hope it helps more people get through their reading in whatever way works for them.")
            }

            pressSection {
                Text("Demo video")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("A one-minute overview of Xarra.")
                    .foregroundStyle(.secondary)

                Embed(youTubeID: "-fBbvx9dTus", title: "Xarra demo: a one-minute overview of the app")
                    .aspectRatio(.r16x9)
                    .frame(maxWidth: 720)
                    .frame(width: .percent(100%))
                    .margin(.vertical, 16)
                    .style(.marginInline, "auto")

                Link("Watch on YouTube", target: "https://youtu.be/-fBbvx9dTus")
                    .style(.display, "block")
                    .style(.width, "fit-content")
                    .style(.marginInline, "auto")
            }

            pressSection {
                Text("Key features")
                    .font(.title2)
                    .fontWeight(.bold)
                Grid(alignment: .topLeading, spacing: 8) {
                    feature("Import content", "Import PDF, EPUB, Markdown, DAISY, plain text, and other documents; share from another app, paste text, add a URL, or browse Project Gutenberg.")
                        .width(6)
                    feature("Follow the text", "Synchronized line highlighting keeps audio and text together. Spoken words can be underlined, highlighted with a background, or left unmarked.")
                        .width(6)
                    feature("Made for Apple devices", "A native experience on iPhone, iPad, Mac, and Apple Vision Pro, with an interface designed for each device.")
                        .width(6)
                    feature("Continue across devices", "Your library and listening position can sync through your private iCloud account.")
                        .width(6)
                    feature("Lightweight and private", "A small app download using Apple's on-device voices. No Xarra account, ads, analytics, or trackers; downloaded content works offline.")
                        .width(6)
                    feature("Accessible interaction", "Supports VoiceOver, Voice Control, Switch Control, Full Keyboard Access, Dynamic Type (including all larger accessibility text sizes), and other system accessibility settings.")
                        .width(6)
                }
                .frame(width: .percent(100%))
            }

            pressSection {
                Text("Screenshots")
                    .font(.title2)
                    .fontWeight(.bold)
                Text {
                    Span("Screenshots, photos, icons, and artwork may be used for editorial coverage of Xarra. Please credit Xarra / Dani Devesa Derksen-Staats for the photos, screenshots, and Xarra artwork, and ")
                    Link("Raúl Gil", target: "https://raul-gil.com/")
                    Span(" for the app icon. Full-resolution files are in the ")
                    Link("downloadable press kit", target: "/Downloads/xarra-press-kit.zip")
                    Span(".")
                }
                .foregroundStyle(.secondary)

                mediaGrid(XarraPressMedia.screenshots, kind: "screenshot")
            }

            pressSection {
                Text("App icon")
                    .font(.title2)
                    .fontWeight(.bold)
                Text {
                    Span("Designed by illustrator ")
                    Link("Raúl Gil", target: "https://raul-gil.com/")
                    Span(".")
                }
                HStack(alignment: .center, spacing: 16) {
                    iconLink(1024)
                    iconLink(512)
                    iconLink(256)
                }
                .style(.flexWrap, "wrap")
            }

            pressSection {
                Text("About the developer")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("Dani Devesa Derksen-Staats is an accessibility specialist and independent developer from Xàbia in the Marina Alta region of the Valencian Community, Spain, and is based in London. He currently works at Yoto and has previously worked at Apple (as a contractor), Spotify, and the BBC. He writes Accessibility up to 11! and is the author of the book Developing Accessible iOS Apps.")

                subsectionTitle("More information")
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

                subsectionTitle("Press contact")
                Link("Dani Devesa Derksen-Staats: \(contactEmail)", target: "mailto:\(contactEmail)")
            }

            pressSection {
                Text("Product photos")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("Photographs by Dani Devesa Derksen-Staats on the Thames Path in Hammersmith, London.")
                    .foregroundStyle(.secondary)

                mediaGrid(XarraPressMedia.photos, kind: "photo")
            }

            pressSection {
                BrandCopy.phrase(prefix: "", brandTitle: app.title, suffix: " 2.0 artwork")
                    .font(.title2)
                    .fontWeight(.bold)

                mediaGrid([XarraPressMedia.eventCard], kind: "artwork", columnWidth: 6)
            }

            pressSection {
                Text("Resumen para medios en español")
                    .font(.title2)
                    .fontWeight(.bold)
                    .attribute("lang", "es")
                Text("Xarra es una app para iPhone, iPad, Mac y Apple Vision Pro creada por Dani Devesa Derksen-Staats, desarrollador independiente de Xàbia afincado en Londres. Su nombre viene de una palabra valenciana/catalana que significa «charlar» o «hablar». Convierte texto en audio, desde artículos y entradas de blog hasta libros y documentos. Puedes leer, escuchar o combinar ambas cosas, con resaltado sincronizado de líneas y, si lo prefieres, de palabras para seguir mejor el texto. Permite importar PDF, EPUB, publicaciones DAISY, enlaces y texto; navegar por capítulos; y continuar en otros dispositivos mediante iCloud. Está disponible en el App Store y se puede descargar gratis, con opciones Premium. El 10% de los ingresos de las suscripciones se dona a AMMEC, una asociación valenciana que apoya a personas con discapacidades físicas y a sus familias. Para entrevistas o materiales de prensa: \(contactEmail).")
                    .attribute("lang", "es")
                Text("En 2026, Xarra fue una de las cinco ganadoras de los Premios Gaady de la GAAD Foundation.")
                    .attribute("lang", "es")
            }
            .id("resumen-es")
            .attribute("lang", "es")
        }
    }

    @MainActor private func pressSection(divider: Bool = true, @HTMLBuilder content: () -> some HTML) -> some HTML {
        let section = VStack(alignment: .leading, spacing: 14) {
            content()
        }
        .padding(.vertical, 24)
        .frame(width: .percent(100%))

        if divider {
            return AnyHTML(section.style(.borderBottom, "1px solid var(--bs-border-color)"))
        } else {
            return AnyHTML(section)
        }
    }

    @MainActor private func subsectionTitle(_ title: String) -> some HTML {
        Text(title)
            .font(.title3)
            .fontWeight(.semibold)
            .padding(.top, 8)
    }

    @MainActor private func fact(_ label: String, _ value: String, divider: Bool = true) -> some HTML {
        fact(label, divider: divider) {
            Text(value)
        }
    }

    @MainActor private func fact(_ label: String, divider: Bool = true, @HTMLBuilder content: () -> some HTML) -> some HTML {
        let item = VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .fontWeight(.bold)
            content()
        }
        .padding(.vertical, 12)
        .style(.overflowWrap, "anywhere")

        if divider {
            return AnyHTML(item.style(.borderBottom, "1px solid var(--bs-border-color)"))
        } else {
            return AnyHTML(item)
        }
    }

    @MainActor private func linkedFact(_ label: String, _ text: String, _ target: String) -> some HTML {
        fact(label) {
            Link(text, target: target)
        }
    }

    @MainActor private func feature(_ title: String, _ description: String) -> some HTML {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .fontWeight(.semibold)
            Text(description)
        }
        .padding(.vertical, 8)
    }

    @MainActor private func mediaGrid(_ items: [XarraPressMedia], kind: String, columnWidth: Int = 4) -> some HTML {
        Grid(alignment: .topLeading, spacing: 24) {
            ForEach(items) { media in
                mediaItem(media, kind: kind)
                    .width(columnWidth)
            }
        }
        .padding(.top, 8)
        .frame(width: .percent(100%))
    }

    @MainActor private func iconLink(_ size: Int) -> some InlineElement {
        Link("Download \(size) × \(size) PNG", target: "\(mediaRoot)xarra-icon-\(size).png")
            .attribute("download", "xarra-icon-\(size).png")
    }

    @MainActor private func mediaItem(_ media: XarraPressMedia, kind: String) -> some HTML {
        VStack(alignment: .leading, spacing: 6) {
            Link(target: mediaRoot + media.filename) {
                Image(mediaRoot + media.filename, description: media.alt)
                    .resizable()
                    .frame(maxWidth: .percent(100%), maxHeight: .px(240))
                    .style(.objectFit, "contain")
            }
            .attribute("aria-label", "View full-size \(media.title) \(kind): \(media.alt)")
            .frame(width: .percent(100%), height: .px(240))
            .style(.display, "flex")
            .style(.alignItems, "center")
            .style(.justifyContent, "center")
            .background("var(--bs-secondary-bg)")

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
                .style(.marginTop, "auto")
        }
        .padding()
        .frame(width: .percent(100%))
        .style(.border, "1px solid var(--bs-border-color)")
        .cornerRadius(6)
        .class("press-media-card")
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
