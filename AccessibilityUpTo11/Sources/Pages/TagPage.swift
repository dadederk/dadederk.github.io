import Foundation
import Ignite

struct MyTagPage: TagPage {
    var body: some HTML {
        VStack(alignment: .leading, spacing: 24) {
            // Page header
            Section {
                Text("Tag: \(tag.name)")
                    .font(.title1)
                    .fontWeight(.bold)
                    .horizontalAlignment(.leading)
            }
            .padding(.vertical)
            
            // Articles with this tag
            Section {
                if !tag.articles.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(tag.articles) { article in
                            ArticlePreview(for: article)
                                .articlePreviewStyle(BlogArticlePreviewStyle())
                        }
                    }
                    .horizontalAlignment(.leading)
                } else {
                    Text("No blog posts found with the tag \"\(tag.name)\".")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .horizontalAlignment(.center)
                        .padding(.vertical)
                }
            }
            .horizontalAlignment(.leading)
        }
        .horizontalAlignment(.leading)
        .padding(.horizontal)
    }
}
