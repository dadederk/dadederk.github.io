# Scripts Directory

This directory contains build scripts and utilities for the Accessibility up to 11! website.

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
