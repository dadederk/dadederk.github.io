# Recognition cards

`hand-drawn-elements.png` preserves Dani's transparent laurel, Apple, and App
Store drawings. `Scripts/GenerateRecognitionCards.swift` embeds the extracted
`laurel.png`, `apple.png`, and `app-store.png` in editable SVGs, mirrors the one
laurel to frame each card, and renders transparent PNGs for the three app pages.

The ratings in `global-ratings-2026-09.json` were collected from Apple's public
App Store lookup service in September 2026. The snapshot records each of the
175 App Store territories, the per-territory rating average and count, and any
request errors. Each worldwide count is the sum of territory counts. Each
worldwide average is weighted by those counts, then displayed to one decimal
place. This is a calculated worldwide figure: Apple's displayed summary rating
is specific to an App Store territory, as [Apple's documentation](https://developer.apple.com/app-store/ratings-and-reviews/)
explains. Helm confirmed the app IDs, but its CLI exposes written reviews,
which differ from total ratings.

The transparent PNGs in `Assets/Images/Site/Apps` are the trailing image on
each app's "What people are saying" banner.

Regenerate after updating the ratings snapshot or extracted artwork. `--check`
verifies that the SVGs and PNGs are current without changing them:

```sh
swift Scripts/GenerateRecognitionCards.swift
swift Scripts/GenerateRecognitionCards.swift --check
```

Update the image descriptions in `Sources/Pages/AppPage.swift` whenever the
figures change.
