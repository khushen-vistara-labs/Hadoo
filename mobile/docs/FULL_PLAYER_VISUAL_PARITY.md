# Full-player screenshot parity — implementation and acceptance criteria

Reference: user's second screenshot (706 × 1536 px); baseline: first screenshot
(706 × 1536 px). This change affects the NEW `FullPlayerScreen` only, not
`ClassicFullPlayerScreen`. The reference images are not committed here.

## Visual audit

| Area | Baseline | Reference | Implemented |
| --- | --- | --- | --- |
| Palette | grey/brown, darkened strongly by black scrims | saturated artwork-derived auburn/brick gradients; legible dark header | high-chroma album palette, three vertical tones and subtle radial glow, reduced duplicate scrim |
| Artwork | ~30 px side margins, large corners | ~40 px side margins, smaller corner radius | 23 logical-pixel horizontal insets and 20 → 12 radius on the normal player stage |
| Title | larger, heavy display text | tighter 29sp/25sp, less heavy, aligned with cover | 700 weight, -0.55 tracking; album and year metadata appended when available |
| Information | artist with prominent yellow quality badge | one understated artist · album · year line | compact neutral metadata; quality remains tappable for song metadata |
| Timeline | low, neon-green active track, light labels | raised slightly, neutral light progress, defined time labels | 24/12 gap before transport, neutral thinner track and semibold time labels |
| Transport | dominant fluorescent play pad, unequal button widths that vary with play/pause | narrower pastel play pad; equal-sized neutral skip pads; consistent radii | album-derived pastel central pad, fixed 36% width and softer secondary pads |
| Volume/action bar | speaker before slider, prominent colored toggles | slider before speaker, narrow divider, subdued icon buttons | reordered speaker, lighter translucent shell, neutral selected controls |
| Chips | bright moving-cover selection, generous horizontal footprint | dense rounded-outline scrollable chips | compact neutral chip padding, outlined surfaces, subdued selection |

Reference colors are **not** fixed constants: a blue, green, or monochrome
cover must retain its own palette. Global appearance accents continue to work
elsewhere. Artwork/Canvas remain the same shared Hero source and the current
player/queue/lyrics animation logic is untouched.

## Functional guardrails

- Preserve tap-to-clear Canvas, swipe next/previous, play/pause animated morph,
  queue and lyrics transitions, Spotify Canvas fallback, volume control, and
  actionable artist/quality metadata.
- Maintain scrolling chips and readable ellipsis/metadata on narrow screens.
- Avoid introducing `BackdropFilter`, new image decodes or extra GPU tickers:
  Ultra performance mode remains compatible.
- Respect system safe areas and reduced-motion preferences.

## Validation

Focused unit/widget tests cover warm/cool/neutral palette handling and three-pad
layout on regular and narrow widths. Full regression suite / Android visual
validation must still be run on device or CI; no pixel-perfect screenshot match
is claimed until comparison at the same scale and playback state.

### On-device comparison

1. Compare the supplied album with and without moving art; note whether Canvas
   is actually available (the reference is a still cover).
2. Inspect a blue cover, a black-and-white cover and a bright/yellow cover.
3. Exercise playing/paused, seek dragging, muted/disabled volume, like/loop,
   chips scrolling, artist and metadata taps.
4. Repeat with Full / Performance / Ultra, lyrics open, queue open, long titles,
   1.5× text scaling, landscape/small handset and fullscreen-cover enabled.
5. Check that closing fullscreen and navigating prev/next preserves the existing
   mini ↔ full artwork morph without a flash or jump.
