# Scripts Directory

This directory contains build scripts and utilities for the Accessibility up to 11! website.

## Social Metadata Validation

### `CheckSocialMeta.swift`

Validates the generated social metadata for representative pages and checks:
- Single canonical link
- Single `twitter:card`
- Presence of OG/Twitter image tags
- Presence of OG/Twitter image alt text
- Presence of OG/Twitter description
- Fallback logo usage on pages expected to fall back

Run from the website root:

```bash
swift Scripts/CheckSocialMeta.swift
```

Force a rebuild before checking:

```bash
swift Scripts/CheckSocialMeta.swift --build
```

Require an existing `Build/` output and never trigger an internal build:

```bash
swift Scripts/CheckSocialMeta.swift --no-build
```

Optional environment overrides:
- `SOCIAL_META_PROJECT_DIR`: project directory that contains `Package.swift`.
- `SOCIAL_META_BUILD_DIR`: explicit build output directory to validate.

### Automatic Build Integration

`CheckSocialMeta.swift` is executed automatically by the main site build (`swift run`) after RSS, sitemap, and image sitemap generation.

To skip it for a local-only run:

```bash
SKIP_SOCIAL_META_CHECK=1 swift run
```

## RSS Feed Generation

### `generate-365-rss.sh`

Generates a proper RSS XML feed for the #365DaysIOSAccessibility content.

**Automatic Generation:**
The RSS feed is now automatically generated after every build. Just run:
```bash
swift run IgniteCLI build
```

**Manual Generation (if needed):**
```bash
./Scripts/generate-365-rss.sh
```

**What it does:**
- Reads all markdown files from `Days365Content/Posts/`
- Parses frontmatter (title, author, date, tags, categories)
- Generates RSS-compliant XML feed with the latest 50 posts
- Outputs to `Build/365-days-feed.rss`

**Features:**
- ✅ Proper XML declaration and RSS 2.0 format
- ✅ Full RSS metadata (title, description, author, etc.)
- ✅ Individual post items with categories and GUIDs
- ✅ RSS feed image and branding
- ✅ Atom self-reference link
- ✅ XML escaping for all content

The generated RSS feed can be subscribed to by any RSS reader and will download as a proper XML file when accessed via web browsers.
