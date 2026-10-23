# Press kits

The site publishes model-driven press pages for Xarra and RetroRapid:

- `/apps/xarra/press/`
- `/apps/retrorapid/press/`

`AppPressContent` owns the shared page experience. Each app supplies an `AppPressKit` configuration, so absent material is omitted rather than represented by placeholders. RetroRapid currently omits its demo-video, developer-photo, product-photo, and localized-summary sections; approved App Store event artwork is available as secondary media.

## What journalists need (checklist)

- Quick facts: price, platforms, availability, developer, privacy, contact
- Paste-ready copy tiers: one sentence, short brief, longer story
- Name origin / pronunciation when the name is unfamiliar
- Social proof (awards, coverage, quotes) when available
- Demo video when you have one (embed + YouTube link)
- Key features (keep an even grid if the layout is multi-column)
- Primary media early (screenshots people will actually use)
- Developer bio and press contact mid-page is fine; secondary media after
- Usage rights on the page, not only in the ZIP README
- Downloadable ZIP with full-resolution assets + README
- Optional: localized summary (Xarra has Spanish) with a jump link from the top actions

## Implementation shape

| Piece | Source |
|---|---|
| Page route | `UniversalAppPage` + `pageType: .press`, enabled by `AppPressKits` |
| Shared layout | `Sources/Pages/AppPressContent.swift` |
| Shared model and registry | `Sources/Models/AppPressKit.swift` |
| Per-app copy and media catalog | `Sources/Models/AppPressKit+<App>.swift` |
| Awards and coverage | Existing `AppsData/<app>.json` fields |
| Full-resolution media | `Assets/Images/Site/Apps/<App>/Press/` |
| Downloadable packs | `Assets/Downloads/<App>PressKit/README.txt` + matching ZIP |

## Layout pattern that worked for Xarra

1. Header + actions (ZIP, Store, product, email, optional language jump)
2. At a glance
3. Awards and coverage (if any)
4. About (pronunciation, one sentence, brief, story)
5. Demo video
6. Key features
7. Primary screenshots (+ usage rights note)
8. App icon
9. About the developer / contact
10. Secondary media (lifestyle photos, event artwork)
11. Optional localized summary

Fragmenting media (primary assets → bio → more assets) is intentional: put the most reusable assets first, keep important context in the middle, and leave lifestyle/secondary media for people who keep scrolling.

## When building another kit

1. Add an `AppPressKit` configuration and register it in `AppPressKits.all`.
2. Add only verified media and copy; leave unavailable optional fields `nil` or empty so their sections do not render.
3. Put full-resolution media under the app's `Press/` folder and keep page copy and ZIP README aligned in the same change.
4. Prefer privacy-friendly YouTube embeds through `AppPressVideo` when a demo exists.
5. Add a publication test covering the route and the app's intentionally absent sections.
6. Do not leave temporary App Review or “coming soon” lines on a live page.
