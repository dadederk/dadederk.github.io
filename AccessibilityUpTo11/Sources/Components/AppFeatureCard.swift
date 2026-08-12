import Foundation
import Ignite

/// A feature card with a consistently sized, meaningfully described image.
struct AppFeatureCard: HTML {
    let feature: FeatureItem
    let fallbackImagePath: String
    let fallbackImageDescription: String

    private var imagePath: String {
        feature.imagePath ?? fallbackImagePath
    }

    private var imageDescription: String {
        guard feature.imagePath != nil else {
            return fallbackImageDescription
        }

        return feature.imageDescription ?? ""
    }

    @MainActor var body: some HTML {
        Section {
            Section {
                Image(imagePath, description: imageDescription)
                    .resizable()
                    .class(ImageOptimizationPolicy.appFeatureImageClass, "object-fit-cover")
            }
                .aspectRatio(.r4x3)
                .class("card-img-top")

            Section {
                Text(feature.title)
                    .font(.title4)
                    .foregroundStyle(.body)
            }
            .class("card-header")

            Section {
                Text(feature.description)
                    .font(.body)
                    .class("card-text")
            }
            .class("card-body")
        }
        .class("card")
    }
}
