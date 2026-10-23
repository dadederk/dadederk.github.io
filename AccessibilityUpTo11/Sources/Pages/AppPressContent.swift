import Ignite

struct AppPressContent: HTML {
    let app: AppItem
    let kit: AppPressKit

    @MainActor var body: some HTML {
        VStack(alignment: .leading, spacing: 0) {
            header
            actions

            pressSection(divider: app.featuredIn.isEmpty) {
                Text("At a glance")
                    .font(.title2)
                    .fontWeight(.bold)

                Grid(alignment: .topLeading, spacing: 24) {
                    ForEach(kit.facts) { fact in
                        factItem(fact)
                            .width(6)
                    }
                }
                .class("glance-facts")
                .frame(width: .percent(100%))
            }

            if !app.featuredIn.isEmpty {
                pressSection(divider: false) {
                    FeaturedInBox(
                        title: kit.recognitionTitle,
                        mentions: app.featuredIn,
                        quote: app.featuredQuote,
                        quoteSourceTitle: app.featuredQuoteSourceTitle,
                        quoteSourceTarget: app.featuredQuoteSourceTarget,
                        trailingImage: kit.recognitionBanner
                    )
                    .style(.width, "100%")
                }
            }

            pressSection {
                BrandCopy.phrase(prefix: "About ", brandTitle: app.title)
                    .font(.title2)
                    .fontWeight(.bold)

                if !app.nameOrigin.isEmpty {
                    Text(app.nameOrigin)
                        .foregroundStyle(.secondary)
                }

                subsectionTitle("One sentence")
                paragraph(kit.about.oneSentence)

                subsectionTitle("In brief")
                ForEach(kit.about.inBrief) { content in
                    paragraph(content)
                }

                if !kit.about.story.isEmpty {
                    subsectionTitle("The story")
                    if let storyLead = kit.about.storyLead {
                        Text(storyLead)
                            .fontWeight(.semibold)
                    }
                    ForEach(kit.about.story) { content in
                        paragraph(content)
                    }
                }
            }

            if let video = kit.demoVideo {
                pressSection {
                    Text(video.title)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(video.description)
                        .foregroundStyle(.secondary)

                    Embed(youTubeID: video.youTubeID, title: "\(app.title) demo: \(video.description)")
                        .aspectRatio(.r16x9)
                        .frame(maxWidth: 720)
                        .frame(width: .percent(100%))
                        .margin(.vertical, 16)
                        .style(.marginInline, "auto")

                    Link("Watch on YouTube", target: video.watchURL)
                        .style(.display, "block")
                        .style(.width, "fit-content")
                        .style(.marginInline, "auto")
                }
            }

            if !kit.features.isEmpty {
                pressSection {
                    Text("Key features")
                        .font(.title2)
                        .fontWeight(.bold)
                    Grid(alignment: .topLeading, spacing: 8) {
                        ForEach(kit.features) { feature in
                            featureItem(feature)
                                .width(6)
                        }
                    }
                    .frame(width: .percent(100%))
                }
            }

            if let screenshots = kit.screenshots, !screenshots.items.isEmpty {
                mediaSection(screenshots)
            }

            if let icons = kit.icons, !icons.downloads.isEmpty {
                iconSection(icons)
            }

            if let developer = kit.developer {
                developerSection(developer)
            }

            ForEach(kit.additionalMediaSections.filter { !$0.items.isEmpty }) { section in
                mediaSection(section)
            }

            if let localizedSummary = kit.localizedSummary {
                localizedSection(localizedSummary)
            }
        }
    }

    @MainActor private var header: some HTML {
        HStack(alignment: .center, spacing: 20) {
            Image(kit.headerIconPath ?? app.imagePath, description: app.imageDescription)
                .resizable()
                .frame(width: 96, height: 96)
                .cornerRadius(20)

            VStack(alignment: .leading, spacing: 6) {
                BrandCopy.phrase(prefix: "", brandTitle: app.title, suffix: " Press Kit")
                    .font(.title1)
                    .fontWeight(.bold)

                Text(kit.tagline)
                    .font(.body)
            }
            .style(.flex, "1 1 auto")
            .style(.minWidth, "0")
        }
        .style(.flexWrap, "wrap")
        .padding(.bottom, 20)
    }

    @MainActor private var actions: some HTML {
        HStack(alignment: .center, spacing: 12) {
            AppStoreDownloadBadge(target: kit.storeURL)

            if let archive = kit.archive {
                Link(archive.title, target: archive.path)
                    .linkStyle(.button)
                    .role(.primary)
                    .attribute("download", archive.filename)
            }

            PillLink(title: "Product page", target: kit.productURL)
            PillLink(title: "Email Dani", target: "mailto:\(app.contactEmail)")

            ForEach(kit.actions) { action in
                PillLink(title: action.title, target: action.target)
            }
        }
        .class("action-row")
        .style(.flexWrap, "wrap")
        .padding()
        .frame(width: .percent(100%))
        .background("var(--bs-secondary-bg)")
        .style(.border, "1px solid var(--bs-border-color)")
        .cornerRadius(6)
    }

    @MainActor private func developerSection(_ developer: AppPressDeveloper) -> some HTML {
        pressSection {
            Text("About the developer")
                .font(.title2)
                .fontWeight(.bold)

            if let photo = developer.photo {
                Grid(alignment: .topLeading, spacing: 24) {
                    developerCopy(developer)
                        .width(7)
                    developerPhoto(photo)
                        .width(5)
                }
                .frame(width: .percent(100%))
            } else {
                developerCopy(developer)
            }
        }
    }

    @MainActor private func developerCopy(_ developer: AppPressDeveloper) -> some HTML {
        VStack(alignment: .leading, spacing: 14) {
            ForEach(developer.bio) { content in
                paragraph(content)
            }

            if !developer.links.isEmpty {
                subsectionTitle(developer.linksTitle)
                List {
                    ForEach(developer.links) { link in
                        ListItem {
                            Link(link.title, target: link.target)
                        }
                    }
                }
            }

            subsectionTitle(developer.contactTitle)
            Link("Dani Devesa Derksen-Staats: \(app.contactEmail)", target: "mailto:\(app.contactEmail)")
        }
    }

    @MainActor private func developerPhoto(_ photo: AppPressPhoto) -> some HTML {
        VStack(alignment: .leading, spacing: 6) {
            Image(photo.path, description: photo.alt)
                .resizable()
                .frame(maxWidth: .percent(100%))
                .cornerRadius(6)
            Text(photo.caption)
                .foregroundStyle(.secondary)
            Link("Download full-resolution photo", target: photo.fullResolutionPath)
                .attribute("download", photo.filename)
        }
    }

    @MainActor private func mediaSection(_ section: AppPressMediaSection) -> some HTML {
        pressSection {
            Text(section.title)
                .font(.title2)
                .fontWeight(.bold)

            ForEach(section.intro) { content in
                paragraph(content, secondary: true)
            }

            mediaGrid(section)
        }
    }

    @MainActor private func iconSection(_ section: AppPressIconSection) -> some HTML {
        pressSection {
            Text("App icon")
                .font(.title2)
                .fontWeight(.bold)

            ForEach(section.intro) { content in
                paragraph(content)
            }

            HStack(alignment: .center, spacing: 16) {
                ForEach(section.downloads) { download in
                    Link(download.title, target: download.path)
                        .attribute("download", download.filename)
                }
            }
            .style(.flexWrap, "wrap")
        }
    }

    @MainActor private func localizedSection(_ summary: AppPressLocalizedSummary) -> some HTML {
        pressSection {
            Text(summary.title)
                .font(.title2)
                .fontWeight(.bold)
                .attribute("lang", summary.language)

            ForEach(summary.paragraphs) { content in
                paragraph(content, language: summary.language)
            }

            ForEach(summary.links) { link in
                Link(link.title, target: link.target)
                    .attribute("lang", summary.language)
            }
        }
        .id(summary.id)
        .attribute("lang", summary.language)
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

    @MainActor private func factItem(_ fact: AppPressFact) -> some HTML {
        VStack(alignment: .leading, spacing: 4) {
            Text(fact.label)
                .fontWeight(.bold)
            paragraph(fact.value)
        }
        .padding(.vertical, 12)
        .style(.overflowWrap, "anywhere")
        .style(.borderBottom, "1px solid var(--bs-border-color)")
    }

    @MainActor private func featureItem(_ feature: AppPressFeature) -> some HTML {
        VStack(alignment: .leading, spacing: 4) {
            Text(feature.title)
                .fontWeight(.semibold)
            Text(feature.description)
        }
        .padding(.vertical, 8)
    }

    @MainActor private func mediaGrid(_ section: AppPressMediaSection) -> some HTML {
        Grid(alignment: .topLeading, spacing: 24) {
            ForEach(section.items) { media in
                mediaItem(media, root: section.root, kind: section.kind)
                    .width(section.columnWidth)
            }
        }
        .padding(.top, 8)
        .frame(width: .percent(100%))
    }

    @MainActor private func mediaItem(_ media: AppPressMedia, root: String, kind: String) -> some HTML {
        let path = root + media.filename

        return VStack(alignment: .leading, spacing: 6) {
            Link(target: path) {
                Image(path, description: media.alt)
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
            Link("Download original", target: path)
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

    @MainActor private func paragraph(
        _ paragraph: AppPressParagraph,
        secondary: Bool = false,
        language: String? = nil
    ) -> some HTML {
        let text = Text {
            InlineForEach(paragraph.fragments) { fragment in
                inlineFragment(fragment)
            }
        }

        let resolvedLanguage = language ?? paragraph.language
        if secondary, let resolvedLanguage {
            return AnyHTML(text.foregroundStyle(.secondary).attribute("lang", resolvedLanguage))
        } else if secondary {
            return AnyHTML(text.foregroundStyle(.secondary))
        } else if let resolvedLanguage {
            return AnyHTML(text.attribute("lang", resolvedLanguage))
        } else {
            return AnyHTML(text)
        }
    }

    @MainActor private func inlineFragment(_ fragment: AppPressFragment) -> some InlineElement {
        switch fragment {
        case .text(let text):
            AnyInlineElement(Span(text))
        case .link(let title, let target):
            AnyInlineElement(Link(title, target: target))
        }
    }
}
