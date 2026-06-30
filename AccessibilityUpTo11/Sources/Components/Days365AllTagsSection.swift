import Foundation
import Ignite

/// Shared browse-by-tag section for #365DaysIOSAccessibility pages.
struct Days365AllTagsSection: HTML {
    @MainActor var body: some HTML {
        let allTags = Days365Loader.allTags()

        if !allTags.isEmpty {
            Section {
                Text("All Tags")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.bottom)

                HStack {
                    ForEach(allTags) { tagName in
                        Link(target: path(forTag: tagName)) {
                            Badge(tagName)
                                .role(.primary)
                        }
                        .relationship(.tag)
                        .margin(.trailing, 8)
                        .margin(.bottom, 8)
                    }
                }
                .style(.flexWrap, "wrap")
            }
            .padding(.top)
            .border(.gray, edges: .top)
            .margin(.top, 8)
        }
    }

    private func path(forTag tag: String) -> String {
        let slug = tag
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: "-")
            .replacingOccurrences(of: "#", with: "")

        return "/365-days-ios-accessibility/tag/\(slug)"
    }
}
