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

                    Text("Xarra turns text into audio so you can get through articles, blog posts, books, and documents your way: read, listen, or do both, with synchronized line and optional word highlighting to help you stay focused.")
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
            }
            .class("xarra-press-actions")

            Section {
                Text("At a glance")
                    .font(.title2)
                    .fontWeight(.bold)

                Section {
                    Section {
                        Text("App").class("xarra-press-fact-label")
                        BrandCopy.phrase(prefix: "", brandTitle: app.title)
                    }
                    .class("xarra-press-fact")
                    fact("Name", "Xarra (pronounced \"CHA-rra\") comes from a Valencian/Catalan word meaning \"to chat\" or \"to talk\".")
                    fact("What it does", "Turns text into audio, from articles and blog posts to books, documents, and notes. Read, listen, or do both, with line and optional word highlighting to help you follow along.")
                    fact("Price", "Free download. Premium: US $1.99/month, $9.99/year, or $29.99 lifetime. Prices may vary by region.")
                    fact("Platforms", "iPhone, iPad, Mac, and Apple Vision Pro")
                    fact("Requirements", "iOS, iPadOS, macOS, or visionOS 26.0 or later, respectively")
                    fact("Availability", "Available now on the App Store")
                    fact("First released", "March 2026")
                    fact("Developer", "Dani Devesa Derksen-Staats, independent developer from Xàbia, based in London")
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
                    linkedFact("Press contact", contactEmail, "mailto:\(contactEmail)")
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

                Text("One sentence")
                    .font(.title3)
                Text("Xarra turns text into audio with a synchronized transcript so people can read, listen, or do both as they work through articles, blog posts, books, and documents.")

                Text("In brief")
                    .font(.title3)
                Text("Bring in an article or blog post, PDF, EPUB, DAISY text publication, URL, or your own writing. Read on screen, listen with Apple voices, or combine both. The current line and, optionally, each spoken word are highlighted to help you stay with the text; chapters and iCloud progress sync help you pick up where you left off.")

                Text("The story")
                    .font(.title3)
                Text("Dani, in his own words:")
                    .fontWeight(.semibold)
                Text("I built Xarra because I was finding it harder and harder to get through long pieces of text, especially on a screen. Listening while reading helped me stay with it; seeing the current line and each spoken word highlighted helped even more. I feel I'm reading more and getting through it faster. I understand it better and have to go back over passages less often. I can also take my reading on a walk or keep going while doing chores. Xarra grew out of wanting one place where I could read, listen, or do both, and move between them without losing my place.")
                Text("From the start, I wanted accessibility and a native experience across Apple platforms to be at the heart of Xarra: the app should meet people where they are, on the devices and with the ways of interacting that already work for them, rather than asking them to adapt to it. I hope it helps more people get through their reading in whatever way works for them.")
            }
            .class("xarra-press-section")

            Section {
                Text("Key features")
                    .font(.title2)
                    .fontWeight(.bold)
                Section {
                    feature("Bring in reading", "Import PDF, EPUB, Markdown, DAISY, plain text, and other documents; share from another app, paste text, add a URL, or browse Project Gutenberg.")
                    feature("Follow the words", "Synchronized line highlighting and optional word highlighting keep audio and text together.")
                    feature("Move through longer work", "Detected headings become chapters, and playback controls let listeners skip and adjust speed.")
                    feature("Made for Apple devices", "A native experience on iPhone, iPad, Mac, and Apple Vision Pro, with an interface designed for each device.")
                    feature("Continue across devices", "Your library and listening position can sync through your private iCloud account.")
                    feature("Lightweight and private", "A small app download using Apple's on-device voices. No Xarra account, ads, analytics, or trackers; downloaded content works offline.")
                    feature("Accessible interaction", "Supports VoiceOver, Voice Control, Switch Control, Full Keyboard Access, Dynamic Type (including Larger Text), and other system accessibility settings.")
                }
                .class("xarra-press-features")
            }
            .class("xarra-press-section")

            Section {
                Text("Screenshots")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("Full-resolution screenshots. View an original in a new tab or download it below, or use the ZIP above.")
                    .foregroundStyle(.secondary)

                Section {
                    ForEach(XarraPressMedia.items) { media in
                        mediaItem(media)
                    }
                }
                .class("xarra-press-media-grid")
            }
            .class("xarra-press-section")

            Section {
                Text("App icon")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("PNG originals for publication. The icon is also in the ZIP.")
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
                Text("Dani Devesa Derksen-Staats is an accessibility specialist and independent developer from Xàbia in Spain's Marina Alta, based in London. He writes Accessibility up to 11! and is the author of Developing Accessible iOS Apps. Xarra is his native Apple app for reading and listening.")

                Text("More information")
                    .font(.title3)
                List {
                    ListItem {
                        Link("About Dani", target: "/about/")
                    }
                    ListItem {
                        Link("Developing Accessible iOS Apps", target: "https://www.springerprofessional.de/en/developing-accessible-ios-apps/17490934")
                    }
                    ListItem {
                        Link("Watch the Double Tap interview", target: "https://www.youtube.com/watch?v=aCqS7Rg41Pg")
                    }
                }

                Text("Press contact")
                    .font(.title3)
                Link("Dani Devesa Derksen-Staats: \(contactEmail)", target: "mailto:\(contactEmail)")
            }
            .class("xarra-press-section")

            Section {
                Text("Resumen para medios en español")
                    .font(.title2)
                    .fontWeight(.bold)
                    .attribute("lang", "es")
                Text("Xarra es una app para iPhone, iPad, Mac y Apple Vision Pro creada por Dani Devesa Derksen-Staats, desarrollador independiente de Xàbia afincado en Londres. Su nombre viene de una palabra valenciana/catalana que significa «charlar» o «hablar». Convierte texto en audio, desde artículos y entradas de blog hasta libros y documentos. Te ayuda a avanzar con tus lecturas: puedes leer, escuchar o combinar ambas cosas, con resaltado sincronizado de líneas y, si quieres, de palabras para seguir mejor el texto. Permite importar PDF, EPUB, publicaciones DAISY, enlaces y texto; navegar por capítulos; y continuar en otros dispositivos mediante iCloud. Está disponible en el App Store y se puede descargar gratis, con opciones Premium. El 10% de los ingresos de las suscripciones se dona a AMMEC, una asociación valenciana que apoya a personas con discapacidades físicas y a sus familias. Para entrevistas o materiales de prensa: \(contactEmail).")
                    .attribute("lang", "es")
            }
            .class("xarra-press-section")
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

    @MainActor private func mediaItem(_ media: XarraPressMedia) -> some HTML {
        Section {
            Link(target: mediaRoot + media.filename) {
                Image(mediaRoot + media.filename, description: media.alt)
                    .resizable()
            }
            .target(.newWindow)
            .relationship(.noOpener)
            Text(media.title)
                .font(.title3)
                .fontWeight(.semibold)
            Text("\(media.platform) · \(media.dimensions)")
                .foregroundStyle(.secondary)
            HStack {
                Link("View full size (new tab)", target: mediaRoot + media.filename)
                    .target(.newWindow)
                    .relationship(.noOpener)
                Link("Download original", target: mediaRoot + media.filename)
                    .attribute("download", media.filename)
            }
            .style(.flexWrap, "wrap")
            .style(.gap, "0.75rem")
        }
        .class("xarra-press-media")
    }
}

private struct XarraPressMedia: Identifiable {
    let filename: String
    let title: String
    let platform: String
    let dimensions: String
    let alt: String

    var id: String { filename }

    static let items: [Self] = [
        .init(filename: "iphone-reading.png", title: "Read and listen", platform: "iPhone", dimensions: "1206 × 2622 px", alt: "Xarra on iPhone reading a welcome document with the current line highlighted and playback controls below."),
        .init(filename: "iphone-word-highlighting.png", title: "Word highlighting", platform: "iPhone", dimensions: "1206 × 2622 px", alt: "Xarra on iPhone in Dark Mode with synchronized line and word highlighting during playback."),
        .init(filename: "iphone-share-import.png", title: "Share into Xarra", platform: "iPhone", dimensions: "1206 × 2622 px", alt: "Xarra on iPhone showing a confirmation after a shared item was imported."),
        .init(filename: "ipad-import-sources.png", title: "Import sources", platform: "iPad", dimensions: "2752 × 2064 px", alt: "Xarra on iPad with the Add menu open beside a readable document, showing text, URL, document, and Gutenberg import options."),
        .init(filename: "ipad-accessibility.png", title: "Larger text and VoiceOver", platform: "iPad", dimensions: "2752 × 2064 px", alt: "Xarra on iPad with enlarged document text and a visible VoiceOver focus outline."),
        .init(filename: "mac-chapters.png", title: "Chapter navigation", platform: "Mac", dimensions: "2160 × 1456 px", alt: "Xarra on Mac showing a Chapters window with detected headings over an open article."),
        .init(filename: "mac-voices.png", title: "Voice preferences", platform: "Mac", dimensions: "2160 × 1456 px", alt: "Xarra on Mac showing voice settings and preferred voices for several languages."),
        .init(filename: "mac-audio-friendly-code.png", title: "Code made listenable", platform: "Mac", dimensions: "2160 × 1456 px", alt: "Xarra on Mac showing an edit window with a Swift code block and a plain-language audio explanation."),
        .init(filename: "vision-reading-room.jpeg", title: "Spatial reading", platform: "Apple Vision Pro", dimensions: "3840 × 2160 px", alt: "Xarra's reading window on Apple Vision Pro in a room, with a library sidebar, transcript, and playback controls."),
        .init(filename: "vision-focus-mode.jpeg", title: "Focus Mode", platform: "Apple Vision Pro", dimensions: "3840 × 2160 px", alt: "Xarra on Apple Vision Pro in Focus Mode, enlarging the current text while keeping reading controls nearby.")
    ]
}
