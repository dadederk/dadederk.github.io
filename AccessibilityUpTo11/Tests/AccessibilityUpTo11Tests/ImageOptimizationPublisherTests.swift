import Foundation
import XCTest
@testable import AccessibilityUpTo11

final class ImageOptimizationPublisherTests: XCTestCase {
    func testProfileUsesDecodedFormatRatherThanExtension() {
        let pngStoredAsJPG = ImageMetadata(
            pixelWidth: 2_048,
            pixelHeight: 1_431,
            format: "PNG",
            channels: "srgb"
        )

        XCTAssertEqual(
            ImageOptimizationPolicy.profile(
                for: "/Images/Other/image122.jpg",
                metadata: pngStoredAsJPG,
                configuration: .empty
            ),
            .graphic
        )
    }

    func testAll365DayPNGFilesWithJPGExtensionsUseLineArtProfile() throws {
        let projectRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let imagesRoot = projectRoot.appendingPathComponent("Assets/Images", isDirectory: true)
        let pngSignature = Data([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])
        let enumerator = try XCTUnwrap(
            FileManager.default.enumerator(
                at: imagesRoot,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
            )
        )

        let disguisedPNGs = enumerator
            .compactMap { $0 as? URL }
            .filter { $0.pathExtension.lowercased() == "jpg" }
            .filter { url in
                guard let data = try? Data(contentsOf: url, options: .mappedIfSafe) else {
                    return false
                }
                return data.prefix(pngSignature.count) == pngSignature
            }

        XCTAssertEqual(disguisedPNGs.count, 20)

        for url in disguisedPNGs {
            let relativePath = url.path.replacingOccurrences(of: imagesRoot.path, with: "/Images")
            let metadata = ImageMetadata(
                pixelWidth: 2_048,
                pixelHeight: 1_431,
                format: "PNG",
                channels: "srgb"
            )
            XCTAssertEqual(
                ImageOptimizationPolicy.profile(
                    for: relativePath,
                    metadata: metadata,
                    configuration: .empty
                ),
                .lineArt,
                relativePath
            )
        }
    }

    func testProductionMetadataDetectsMislabeledPNG() throws {
        let projectRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let source = projectRoot
            .appendingPathComponent("Assets/Images/365DaysIOSAccessibility/image122.jpg")
        let tools = try ImageOptimizationToolchain.locate()

        let metadata = try ImageOptimizationPublisher.metadata(for: source, using: tools)

        XCTAssertEqual(metadata.format, "PNG")
        XCTAssertEqual(
            ImageOptimizationPolicy.profile(
                for: "/Images/365DaysIOSAccessibility/image122.jpg",
                metadata: metadata,
                configuration: .empty
            ),
            .lineArt
        )
    }

    func testIllustratedBlogSeriesUseLineArtProfile() {
        let metadata = ImageMetadata(pixelWidth: 2_048, pixelHeight: 1_431, format: "PNG", channels: "srgb")

        for path in [
            "/Images/Posts/2021-01-21-01/Traits.png",
            "/Images/Posts/2024-12-06-01/Day12.png",
            "/Images/Posts/2026-02-22-01/RetroRapidWatch.png"
        ] {
            XCTAssertEqual(
                ImageOptimizationPolicy.profile(for: path, metadata: metadata, configuration: .empty),
                .lineArt,
                path
            )
        }

        XCTAssertEqual(
            ImageOptimizationPolicy.profile(
                for: "/Images/Posts/2020-08-11-01/AccessibilityInspectorAudit.png",
                metadata: metadata,
                configuration: .empty
            ),
            .graphic
        )
    }

    func testEncodingArgumentsPrioritizePhotoAndLineArtQuality() {
        XCTAssertEqual(
            ImageOptimizationPolicy.cwebpArguments(for: .photo),
            ["-q", "95", "-sharp_yuv", "-metadata", "icc"]
        )
        XCTAssertEqual(
            ImageOptimizationPolicy.cwebpArguments(for: .lineArt),
            ["-lossless", "-z", "6", "-exact", "-metadata", "icc"]
        )
    }

    func testExactPathOverrideWinsOverAutomaticProfile() {
        let path = "/Images/Site/Apps/Example/Photograph.png"
        let configuration = ImageOptimizationConfiguration(overrides: [path: .photo])
        let metadata = ImageMetadata(pixelWidth: 1_200, pixelHeight: 900, format: "PNG", channels: "srgba")

        XCTAssertEqual(
            ImageOptimizationPolicy.profile(for: path, metadata: metadata, configuration: configuration),
            .photo
        )
    }

    func testTransparentGlobalBrandAssetUsesLosslessProfile() {
        let metadata = ImageMetadata(pixelWidth: 512, pixelHeight: 512, format: "PNG", channels: "srgba")

        XCTAssertEqual(
            ImageOptimizationPolicy.profile(
                for: "/Images/Site/Global/FutureBrandAsset.png",
                metadata: metadata,
                configuration: .empty
            ),
            .lossless
        )
        XCTAssertEqual(
            ImageOptimizationPolicy.profile(
                for: "/Images/Posts/TransparentScreenshot.png",
                metadata: metadata,
                configuration: .empty
            ),
            .graphic
        )
    }

    func testTargetWidthsNeverUpscaleAndIncludeNativeMaximum() {
        XCTAssertEqual(
            ImageOptimizationPolicy.targetWidths(
                for: "/Images/Posts/example.png",
                sourceWidth: 1_125
            ),
            [400, 800, 1_125]
        )
        XCTAssertEqual(
            ImageOptimizationPolicy.targetWidths(
                for: "/Images/Posts/small.png",
                sourceWidth: 300
            ),
            [300]
        )
        XCTAssertEqual(
            ImageOptimizationPolicy.targetWidths(
                for: "/Images/Site/Apps/ExampleIcon.png",
                sourceWidth: 512
            ),
            [96, 192, 264, 396]
        )
    }

    func testPrepareForPublishingRemovesOnlyGeneratedBuildDirectory() throws {
        let temporaryProject = FileManager.default.temporaryDirectory
            .appendingPathComponent("image-optimization-tests-\(UUID().uuidString)", isDirectory: true)
        let buildDirectory = temporaryProject.appendingPathComponent("Build", isDirectory: true)
        let assetsDirectory = temporaryProject.appendingPathComponent("Assets", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: temporaryProject) }

        try FileManager.default.createDirectory(at: buildDirectory, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: assetsDirectory, withIntermediateDirectories: true)
        try Data("generated".utf8).write(to: buildDirectory.appendingPathComponent("marker"))
        try Data("source".utf8).write(to: assetsDirectory.appendingPathComponent("marker"))

        try ImageOptimizationPublisher.prepareForPublishing(projectDirectory: temporaryProject)

        XCTAssertFalse(FileManager.default.fileExists(atPath: buildDirectory.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: assetsDirectory.appendingPathComponent("marker").path))
    }

    func testPreflightFailsBeforeTouchingExistingBuildOutput() throws {
        let temporaryProject = FileManager.default.temporaryDirectory
            .appendingPathComponent("image-preflight-tests-\(UUID().uuidString)", isDirectory: true)
        let buildMarker = temporaryProject
            .appendingPathComponent("Build", isDirectory: true)
            .appendingPathComponent("marker")
        defer { try? FileManager.default.removeItem(at: temporaryProject) }

        try FileManager.default.createDirectory(
            at: buildMarker.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try Data("existing output".utf8).write(to: buildMarker)

        XCTAssertThrowsError(
            try ImageOptimizationPublisher.preflight(
                projectDirectory: temporaryProject,
                environment: ["PATH": ""]
            )
        )
        XCTAssertTrue(FileManager.default.fileExists(atPath: buildMarker.path))
    }

    func testDerivativePathIsDeterministicAndURLSafe() {
        XCTAssertEqual(
            ImageOptimizationPublisher.derivativeWebPath(
                for: "/Images/Site/More Content/Podcasts/SwiftOverCoffee.jpeg",
                width: 800
            ),
            "/Images/Optimized/Site/More%20Content/Podcasts/SwiftOverCoffee.jpeg-w800.webp"
        )
    }

    func testHTMLRewritePreservesAttributesAndAssignsLoadingPriorities() throws {
        let navigationLogo = asset(
            path: "/Images/Site/Global/Logo.png",
            width: 532,
            height: 508,
            derivativeWidths: [64, 128],
            profile: .lossless
        )
        let firstImage = asset(
            path: "/Images/Posts/Test Image.jpg",
            width: 1_600,
            height: 900,
            derivativeWidths: [400, 800, 1_200, 1_440],
            profile: .photo
        )
        let secondImage = asset(
            path: "/Images/Posts/Second.png",
            width: 1_200,
            height: 800,
            derivativeWidths: [400, 800, 1_200],
            profile: .graphic
        )
        let footerLogo = asset(
            path: "/Images/Site/Global/swift-for-swifts-small.png",
            width: 256,
            height: 284,
            derivativeWidths: [32, 64],
            profile: .lossless
        )
        let assets = Dictionary(
            uniqueKeysWithValues: [navigationLogo, firstImage, secondImage, footerLogo].map { ($0.sourcePath, $0) }
        )
        let rewriter = ImageHTMLRewriter(
            assets: assets,
            faviconPath: "/Images/Optimized/favicon-32.png",
            searchFaviconPath: "/Images/Optimized/favicon-96.png",
            appleTouchIconPath: "/Images/Optimized/favicon-180.png"
        )
        let html = """
        <html><head>
        <link href="/Images/Site/Global/a11yupto11favicon.png" rel="icon" />
        <link href="/Images/Site/Global/a11yupto11favicon.png" rel="apple-touch-icon" />
        </head><body data-current-page="/about">
        <nav><img src="/Images/Site/Global/Logo.png" alt="Site logo" class="img-fluid logo-light site-logo" /></nav>
        <div id="main-content">
        <img src="/Images/Posts/Test%20Image.jpg" alt="Meaningful description" class="img-fluid align-self-center" style="border-radius: 8px" />
        <img src="/Images/Posts/Second.png" alt="Second description" class="img-fluid" />
        </div>
        <footer><img src="/Images/Site/Global/swift-for-swifts-small.png" alt="" class="img-fluid" /></footer>
        </body></html>
        """

        let rewritten = try rewriter.rewrite(html)

        XCTAssertEqual(rewritten.components(separatedBy: "<picture").count - 1, 4)
        XCTAssertTrue(rewritten.contains(#"alt="Meaningful description" class="img-fluid align-self-center" style="border-radius: 8px""#))
        XCTAssertTrue(rewritten.contains(#"width="1600" height="900" decoding="async" data-image-optimized="true" loading="eager" fetchpriority="high""#))
        XCTAssertTrue(rewritten.contains(#"width="1200" height="800" decoding="async" data-image-optimized="true" loading="lazy" fetchpriority="low""#))
        XCTAssertTrue(rewritten.contains(#"class="responsive-picture logo-light-picture""#))
        XCTAssertTrue(rewritten.contains(#"class="responsive-picture align-self-center""#))
        XCTAssertTrue(rewritten.contains(#"sizes="(min-width: 768px) 50vw, calc(100vw - 40px)""#))
        XCTAssertTrue(rewritten.contains(#"href="/Images/Optimized/favicon-32.png" sizes="32x32" type="image/png""#))
        XCTAssertTrue(rewritten.contains(#"href="/Images/Optimized/favicon-96.png" sizes="96x96" type="image/png""#))
        XCTAssertTrue(rewritten.contains(#"href="/Images/Optimized/favicon-180.png" sizes="180x180" type="image/png""#))

        XCTAssertEqual(try rewriter.rewrite(rewritten), rewritten)
    }

    func testArticleImageBelowHeaderRemainsLazy() throws {
        let firstImage = asset(
            path: "/Images/Posts/Lead.png",
            width: 1_600,
            height: 900,
            derivativeWidths: [400, 800, 1_200, 1_440],
            profile: .graphic
        )
        let rewriter = ImageHTMLRewriter(
            assets: [firstImage.sourcePath: firstImage],
            faviconPath: "/Images/Optimized/favicon-32.png",
            searchFaviconPath: "/Images/Optimized/favicon-96.png",
            appleTouchIconPath: "/Images/Optimized/favicon-180.png"
        )
        let html = """
        <html><head></head><body data-current-page='/post/example'>
        <div id='main-content'><h1>Article</h1><p>Introduction</p>
        <img src='/Images/Posts/Lead.png' alt='Lead image'>
        </div></body></html>
        """

        let rewritten = try rewriter.rewrite(html)

        XCTAssertTrue(rewritten.contains(#"loading="lazy""#))
        XCTAssertTrue(rewritten.contains(#"fetchpriority="low""#))
        XCTAssertFalse(rewritten.contains(#"fetchpriority="high""#))
        XCTAssertTrue(rewritten.contains(#"sizes="(min-width: 744px) 720px, calc(100vw - 24px)""#))
    }

    func testCardAndAppIconSizesAreContextSpecific() {
        XCTAssertEqual(
            ImageHTMLRewriter.sizesValue(
                for: #"<img class="card-img-top" />"#,
                sourcePath: "/Images/Posts/card.png"
            ),
            "(min-width: 1400px) 416px, (min-width: 768px) 33vw, calc(100vw - 40px)"
        )
        XCTAssertEqual(
            ImageHTMLRewriter.sizesValue(
                for: #"<img class="img-fluid app-feature-image object-fit-cover" />"#,
                sourcePath: "/Images/Site/Apps/Example/Feature.png"
            ),
            "(min-width: 1400px) 416px, (min-width: 768px) 33vw, calc(100vw - 40px)"
        )
        XCTAssertEqual(
            ImageHTMLRewriter.sizesValue(
                for: #"<img style="width: 96px; height: 96px" />"#,
                sourcePath: "/Images/Site/Apps/ExampleIcon.png"
            ),
            "96px"
        )
    }

    func testRepresentativeCandidateSelectionUsesMobileRetinaWidth() {
        let sourceSet = "/image-400.webp 400w, /image-800.webp 800w, /image-1200.webp 1200w"

        XCTAssertEqual(
            RepresentativeImageTransferValidator.selectedCandidatePath(
                sourceSet: sourceSet,
                sizes: "(min-width: 744px) 720px, calc(100vw - 24px)"
            ),
            "/image-800.webp"
        )
        XCTAssertEqual(
            RepresentativeImageTransferValidator.renderedCSSWidth(sizes: "96px"),
            96
        )
    }

    func testValidatorRejectsLocalImageWithoutResponsivePicture() throws {
        let temporaryBuild = FileManager.default.temporaryDirectory
            .appendingPathComponent("image-validator-tests-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: temporaryBuild) }
        let image = temporaryBuild.appendingPathComponent("Images/example.png")
        let htmlFile = temporaryBuild.appendingPathComponent("index.html")
        try FileManager.default.createDirectory(at: image.deletingLastPathComponent(), withIntermediateDirectories: true)
        try Data("source".utf8).write(to: image)
        try """
        <html><head></head><body>
        <img src='/Images/example.png' alt='Example' width='10' height='10'
             decoding='async' data-image-optimized='true' loading='lazy'>
        </body></html>
        """.write(to: htmlFile, atomically: true, encoding: .utf8)

        XCTAssertThrowsError(
            try GeneratedImageValidator.validate(htmlFiles: [htmlFile], buildDirectory: temporaryBuild)
        )
    }

    private func asset(
        path: String,
        width: Int,
        height: Int,
        derivativeWidths: [Int],
        profile: ImageEncodingProfile
    ) -> OptimizedImageAsset {
        let derivatives = derivativeWidths.map { derivativeWidth in
            ImageDerivative(
                pixelWidth: derivativeWidth,
                webPath: ImageOptimizationPublisher.derivativeWebPath(for: path, width: derivativeWidth),
                fileURL: FileManager.default.temporaryDirectory
                    .appendingPathComponent("image-\(derivativeWidth).webp")
            )
        }
        return OptimizedImageAsset(
            sourcePath: path,
            metadata: ImageMetadata(
                pixelWidth: width,
                pixelHeight: height,
                format: profile == .photo ? "JPEG" : "PNG",
                channels: profile == .lossless ? "srgba" : "srgb"
            ),
            profile: profile,
            derivatives: derivatives
        )
    }
}
