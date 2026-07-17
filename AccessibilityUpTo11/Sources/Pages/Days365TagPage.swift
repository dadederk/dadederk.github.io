import Foundation
import Ignite

struct Days365TagPage: StaticPage {
    let tag: String
    let pageNumber: Int

    private var tagSlug: String {
        tag.lowercased().replacingOccurrences(of: " ", with: "-")
    }

    private var basePath: String {
        "/365-days-ios-accessibility/tag/\(tagSlug)"
    }

    private func path(forPage page: Int) -> String {
        page == 1 ? basePath : "\(basePath)/page-\(page)"
    }

    var title: String {
        pageNumber == 1
            ? "Tag: \(tag) - #365DaysIOSAccessibility"
            : "Tag: \(tag) - Page \(pageNumber) - #365DaysIOSAccessibility"
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
                    Text("Tag: \(tag)")
                        .font(.title2)
                        .class("text-break")

                    let posts = Days365Loader.posts(withTag: tag)
                    Text("\(posts.count) post\(posts.count == 1 ? "" : "s")")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                .style(.flexWrap, "wrap")
                .style(.gap, "0.5rem")
                .padding(.bottom)

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

enum Days365TagPagination {
    static let postsPerPage = 12

    static func totalPages(forPostCount count: Int) -> Int {
        max(1, (count + postsPerPage - 1) / postsPerPage)
    }
}
