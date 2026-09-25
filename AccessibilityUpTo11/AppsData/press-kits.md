# Press kits — notes for future apps

Xarra’s press kit (`/apps/xarra/press/`) is the first full press page on this site. It is intentionally Xarra-specific for now. When adding kits for other apps (for example RetroRapid!), use these notes so we do not rebuild the same decisions from scratch.

## What journalists need (checklist)

- Quick facts: price, platforms, availability, developer, privacy, contact
- Paste-ready copy tiers: one sentence, short brief, longer story
- Name origin / pronunciation when the name is unfamiliar
- Social proof (coverage, quotes) when available
- Demo video when you have one (embed + YouTube link)
- Key features (keep an even grid if the layout is multi-column)
- Primary media early (screenshots people will actually use)
- Developer bio and press contact mid-page is fine; secondary media after
- Usage rights on the page, not only in the ZIP README
- Downloadable ZIP with full-resolution assets + README
- Optional: localized summary (Xarra has Spanish) with a jump link from the top actions

## Current implementation shape

| Piece | Today (Xarra) | Future direction |
|---|---|---|
| Page route | `UniversalAppPage` + `pageType: .press` | Keep; one press route per app slug |
| Content | Hardcoded `XarraPressContent.swift` | Shared layout/components + per-app content (JSON, markdown, or a small Swift model) |
| Media catalog | Private `XarraPressMedia` in the same file | Per-app media list (paths, titles, alts, kinds) |
| ZIP | Manual `Assets/Downloads/xarra-press-kit.zip` + `XarraPressKit/README.txt` | Scripted pack from a per-app folder so page and ZIP cannot drift |
| URLs / pricing | Hardcoded in the press page | Prefer `AppsData` / app JSON fields already used on the product page |
| Featured coverage | Already from `xarra.json` | Keep sourcing social proof from app JSON |

## Layout pattern that worked for Xarra

1. Header + actions (ZIP, Store, product, email, optional language jump)
2. At a glance
3. Featured in (if any)
4. About (pronunciation, one sentence, brief, story)
5. Demo video
6. Key features
7. Primary screenshots (+ usage rights note)
8. App icon
9. About the developer / contact
10. Secondary media (lifestyle photos, event artwork)
11. Optional localized summary

Fragmenting media (primary assets → bio → more assets) is intentional: put the most reusable assets first, keep important context in the middle, and leave lifestyle/secondary media for people who keep scrolling.

## When building the next kit

1. Copy the Xarra structure; swap facts, copy, media, and ZIP.
2. Extract shared UI only after the second kit exists (actions strip, facts grid, media card, usage blurb, demo section).
3. Keep page copy and ZIP README aligned in the same change.
4. Prefer privacy-friendly YouTube embeds (`Embed(youTubeID:title:)` + `.aspectRatio(.r16x9)`).
5. Do not leave temporary App Review / “coming soon” lines on the live page once they no longer apply.
