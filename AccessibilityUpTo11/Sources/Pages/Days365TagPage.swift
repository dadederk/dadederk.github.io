import Foundation
import Ignite

struct Days365TagPage: StaticPage {
    let tag: String
    let pageNumber: Int

    private var tagSlug: String {
        Days365Loader.tagSlug(for: tag)
    }

    private var basePath: String {
        "/365-days-ios-accessibility/tag/\(tagSlug)"
    }

    private func path(forPage page: Int) -> String {
        page == 1 ? basePath : "\(basePath)/page-\(page)"
    }

    var title: String {
        pageNumber == 1
            ? "\(tag) Accessibility Tips for iOS Developers"
            : "\(tag) Accessibility Tips - Page \(pageNumber)"
    }

    var path: String { path(forPage: pageNumber) }

    var description: String {
        let count = Days365Loader.posts(withTag: tag).count
        if pageNumber == 1 {
            return "Browse \(count) #365DaysIOSAccessibility post\(count == 1 ? "" : "s") tagged \(tag)."
        }
        return "Page \(pageNumber) of #365DaysIOSAccessibility posts tagged \(tag)."
    }

    var image: URL? {
        let taggedImage = Days365Loader.posts(withTag: tag).first(where: { $0.image != nil })?.image
        return SiteMeta.imageURL(taggedImage)
    }

    var body: some HTML {
        let breadcrumbData = BreadcrumbListStructuredData.json(
            crumbs: BreadcrumbListStructuredData.days365TagCrumbs(tag: tag, pagePath: path)
        )

        Script(code: breadcrumbData)
            .attribute("type", "application/ld+json")

        VStack(alignment: .leading) {
            // Breadcrumb navigation
            Section {
                Link("#365DaysIOSAccessibility", target: "/365-days-ios-accessibility")
                    .foregroundStyle(.primary)
                    .font(.body)
                    .class("text-break")
                    .horizontalAlignment(.leading)
            }
            .horizontalAlignment(.leading)
            .padding(.bottom)

            // Page header
            Section {
                HStack(alignment: .bottom) {
                    Text("\(tag) Accessibility Tips for iOS Developers")
                        .font(.title1)
                        .fontWeight(.bold)
                        .class("text-break")

                    let posts = Days365Loader.posts(withTag: tag)
                    Text("\(posts.count) post\(posts.count == 1 ? "" : "s")")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                .style(.flexWrap, "wrap")
                .style(.gap, "0.5rem")
                .padding(.bottom)

                if pageNumber == 1 {
                    Text(Self.topicIntroduction(for: tag))
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .class("text-break")
                        .padding(.bottom)
                }

                let allPosts = Days365Loader.posts(withTag: tag)
                let postsPerPage = Days365TagPagination.postsPerPage
                let startIndex = (pageNumber - 1) * postsPerPage
                let endIndex = min(startIndex + postsPerPage, allPosts.count)
                let postsToShow = startIndex < allPosts.count
                    ? Array(allPosts[startIndex..<endIndex])
                    : []
                let totalPages = Days365TagPagination.totalPages(forPostCount: allPosts.count)

                if !postsToShow.isEmpty {
                    Grid(alignment: .topLeading) {
                        ForEach(postsToShow) { post in
                            Days365AsArticlePreview(post: post)
                                .width(4)
                        }
                    }

                    if totalPages > 1 {
                        Section {
                            VStack(spacing: 16) {
                                Text("Showing \(startIndex + 1)-\(endIndex) of \(allPosts.count) posts")
                                    .font(.body)
                                    .foregroundStyle(.secondary)

                                HStack(spacing: 12) {
                                    if pageNumber > 1 {
                                        Link("← Previous", target: path(forPage: pageNumber - 1))
                                            .padding(.vertical, .small)
                                            .padding(.horizontal)
                                            .border(.gray)
                                            .cornerRadius(6)
                                    } else {
                                        Text("← Previous")
                                            .padding(.vertical, .small)
                                            .padding(.horizontal)
                                            .border(.gray)
                                            .cornerRadius(6)
                                            .foregroundStyle(.secondary)
                                            .style(.opacity, "0.6")
                                    }

                                    Spacer()

                                    Text("Page \(pageNumber) of \(totalPages)")
                                        .font(.body)
                                        .foregroundStyle(.secondary)

                                    Spacer()

                                    if pageNumber < totalPages {
                                        Link("Next →", target: path(forPage: pageNumber + 1))
                                            .padding(.vertical, .small)
                                            .padding(.horizontal)
                                            .border(.gray)
                                            .cornerRadius(6)
                                    } else {
                                        Text("Next →")
                                            .padding(.vertical, .small)
                                            .padding(.horizontal)
                                            .border(.gray)
                                            .cornerRadius(6)
                                            .foregroundStyle(.secondary)
                                            .style(.opacity, "0.6")
                                    }
                                }
                            }
                        }
                        .padding(.top)
                        .padding(.horizontal)
                    }
                } else {
                    Text("No posts found with the tag \"\(tag)\".")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .padding(.vertical)
                }
            }
            .padding(.bottom)

            Days365AllTagsSection()
        }
        .horizontalAlignment(.leading)
    }
}

extension Days365TagPage {
    static func topicIntroduction(for tag: String) -> String {
        let introductions = [
            "voiceover": "Practical VoiceOver guidance for iOS developers, covering accessible names, navigation order, custom controls, focus, announcements, and hands-on testing.",
            "swiftui": "SwiftUI accessibility techniques for building clear semantics, scalable interfaces, predictable focus, and controls that work well with assistive technologies.",
            "uikit": "UIKit accessibility patterns for exposing useful semantics, grouping content, managing focus, supporting custom interactions, and testing real interfaces.",
            "accessibilitylabel": "Examples and guidance for writing useful accessibility labels that identify controls clearly without repeating traits, state, or surrounding context.",
            "dynamic-type": "Dynamic Type techniques for readable, resilient iOS layouts that scale with the user's preferred text size without clipping or hiding content.",
            "accessibility-inspector": "Ways to use Accessibility Inspector to audit labels, traits, values, contrast, hit targets, and navigation before testing on a device.",
            "voice-control": "Voice Control implementation and testing guidance for interfaces that remain discoverable and operable without touch.",
            "full-keyboard-access": "Full Keyboard Access patterns for logical focus order, visible focus, keyboard-operable controls, and efficient iPad navigation.",
            "switch-control": "Switch Control guidance for predictable scanning, meaningful grouping, usable actions, and interfaces that do not depend on precise gestures.",
        ]

        return introductions[Days365Loader.tagSlug(for: tag)]
            ?? "Browse practical #365DaysIOSAccessibility notes, examples, and implementation ideas related to \(tag)."
    }
}

enum Days365TagPagination {
    static let postsPerPage = 12

    static func totalPages(forPostCount count: Int) -> Int {
        max(1, (count + postsPerPage - 1) / postsPerPage)
    }
}
