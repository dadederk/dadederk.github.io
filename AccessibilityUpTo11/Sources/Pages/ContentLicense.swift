import Foundation
import Ignite

struct ContentLicense: StaticPage {
    var title = "Content License"
    var path = SiteMeta.contentLicensePath
    var description = "Reuse and adaptation terms for written content published on Accessibility up to 11."

    @MainActor var body: some HTML {
        VStack(alignment: .leading) {
            Text("Content License")
                .font(.title1)
                .fontWeight(.bold)
                .horizontalAlignment(.leading)
                .padding(.bottom, 10)

            MarkdownRenderer(
                content: """
                Content published on Accessibility up to 11 is licensed under [\(SiteMeta.contentLicenseName)](\(SiteMeta.contentLicenseURL)).

                ## You are free to

                - Share: copy and redistribute the material in any medium or format.
                - Adapt: remix, transform, and build upon the material for any purpose, including commercial use.

                ## Attribution requirements

                When reusing or adapting content, please:

                - Credit the author: Daniel Devesa Derksen-Staats.
                - Cite the source: Accessibility up to 11 (https://accessibilityupto11.com).
                - Link to the original page whenever possible.
                - Link to the license: \(SiteMeta.contentLicenseURL).
                - Indicate if changes were made.

                ## Scope and exclusions

                This license applies to original written content and original media on this site unless a page states otherwise.

                Third-party trademarks, logos, and externally sourced media keep their own licenses and rights.

                ## Code license

                Source code in this repository remains under the MIT license and is separate from this content license.

                ## Preferred attribution example

                "Originally published by Daniel Devesa Derksen-Staats on Accessibility up to 11 (https://accessibilityupto11.com), licensed under CC BY 4.0. Modified for brevity."
                """
            )
            .class("post-content")
            .horizontalAlignment(.leading)
        }
    }
}
