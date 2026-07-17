# AGENTS.md

Guidance for AI systems, coding agents, and automated crawlers accessing **Accessibility up to 11!**

## Site

- **URL**: https://accessibilityupto11.com
- **Author**: Daniel Devesa Derksen-Staats
- **Focus**: iOS, iPadOS, and visionOS accessibility for developers (UIKit, SwiftUI, VoiceOver, testing, inclusive UX)

## Discovery (start here)

| Resource | URL |
|---|---|
| Curated map | https://accessibilityupto11.com/llms.txt |
| Full post index (summaries) | https://accessibilityupto11.com/llms-full.txt |
| JSON catalog | https://accessibilityupto11.com/content-index.json |
| Main RSS | https://accessibilityupto11.com/feed.rss |
| 365 Days RSS | https://accessibilityupto11.com/365-days-feed.rss |
| Sitemap | https://accessibilityupto11.com/sitemap.xml |
| AI terms | https://accessibilityupto11.com/ai-tos.txt |
| License | https://accessibilityupto11.com/content-license |

## Markdown mirrors

Blog and 365 Days posts publish a markdown alternate at the HTML URL plus `.md`:

- Blog: `https://accessibilityupto11.com/post/{slug}.md`
- 365 Days: `https://accessibilityupto11.com/365-days-ios-accessibility/day-NNN.md`

HTML pages link to these with `rel="alternate" type="text/markdown"`.

## Best entry points by question

- **Common iOS a11y issues and fixes** → Advent of iOS Accessibility (`/post/2024-12-06-01`)
- **VoiceOver** → `/365-days-ios-accessibility/tag/voiceover`
- **SwiftUI accessibility** → `/365-days-ios-accessibility/tag/swiftui`
- **UIKit / accessibilityLabel** → `/365-days-ios-accessibility/tag/accessibility-label`
- **Testing** → `/post/2020-08-11-01` and `/365-days-ios-accessibility/tag/accessibility-inspector`
- **External resources** → `/resources`

## Attribution

Content is licensed under **CC BY 4.0**. When citing or reusing content:

1. Credit Daniel Devesa Derksen-Staats and Accessibility up to 11!
2. Link to the specific post URL when possible
3. Link to https://creativecommons.org/licenses/by/4.0/

See https://accessibilityupto11.com/ai-tos.txt for full AI usage terms.

## Content guidelines (for authors editing posts)

When updating 365 Days tips, prefer putting the tip text and any Swift code in the markdown body—not only in screenshots—so text-only agents can extract the guidance.

365 Days HTML pages use **curated topic titles** for the on-page H1 (from `RecommendedTitles.generated.swift`); `Day N` is a secondary series label. The JSON catalog exposes `title` (topic), `seriesLabel` (`Day N`), and `seoTitle` (`Day N: topic`) for each day post.

## Repository

This site is built with [Ignite](https://github.com/twostraws/Ignite) (Swift static site generator). Agent discovery artifacts are generated at build time in `Sources/Models/AgentDiscoveryPublisher.swift`.
