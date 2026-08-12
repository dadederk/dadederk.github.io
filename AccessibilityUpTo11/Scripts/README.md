# Scripts Directory

This directory contains build scripts and utilities for the Accessibility up to 11! website.

## Brand Mark

Site and app names use a trailing `!` as the brand mark (e.g. **Xarra!**, **Mestre!**, **RetroRapid!**, **Accessibility up to 11!**).

| Context | Treatment |
|---|---|
| Nav titles, app names, buttons, card titles | `Name!` with italic `!` in rendered HTML |
| Mid-sentence UI when easy (e.g. "Why Xarra!?") | Keep the brand mark; italicize `!`; keep trailing punctuation |
| Plain strings, metadata, JSON prose | Plain `!` or no mark when it reads more naturally |
| App Store listing names, slugs, bundle IDs | No `!` |

Implementation: `Sources/Utilities/BrandCopy.swift`.

## Responsive image optimisation

Every normal site build keeps the files in `Assets/Images` as canonical fallbacks, then generates responsive WebP derivatives under the ignored `Build/Images/Optimized` directory. Generated HTML is rewritten with `picture`, `srcset`, intrinsic dimensions, async decoding, and eager/lazy loading hints before validation.

Local and CI builds require WebP tools and ImageMagick:

```bash
brew install webp imagemagick
```

Ubuntu CI installs the equivalent `webp` and `imagemagick` packages. Encoding is selected from the decoded image format, with exact lossless treatment for the site's illustration collections and retained ICC colour profiles. Exact-path exceptions can be declared in `ImageOptimizationConfig.json` using the `photo`, `graphic`, `line-art`, or `lossless` profile.

For a deliberately unoptimised local build only:

```bash
SKIP_IMAGE_OPTIMIZATION=1 ignite build
```

Production builds must not set that override. The optimiser validates every generated local image and fails the build if a derivative, responsive source set, intrinsic dimension, or loading hint is missing.

The production gate also enforces the 32px browser, 96px Search, and 180px Apple-touch favicon budgets plus at least 70% estimated image-transfer reduction across representative pages at a 390px-wide 2x viewport. Article images remain lazy with low fetch priority; listing, app, and profile pages may promote their first meaningful visible image.

Image encoding uses a bounded worker pool so a normal optimised build completes promptly. Set `IMAGE_OPTIMIZATION_WORKERS` only when you need to reduce or increase its default limit of six concurrent source images.

## 365 Days title regeneration

After editing the local gitignored `Days365Content/recommended-titles.md`:

```bash
swift Scripts/RegenerateRecommendedTitles.swift
```

Commit the updated `Sources/Models/RecommendedTitles.generated.swift`.

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

`CheckSocialMeta.swift` is executed automatically by the main site build (`swift run`) after RSS, sitemap, image sitemap, robots, and AASA generation.

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
ignite build
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
