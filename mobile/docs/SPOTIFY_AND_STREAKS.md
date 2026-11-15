# Spotify sessions, new likes and synced streaks

This follow-up addresses Spotify Canvas/Discovery failures, historical likes
being imported on activation, missing desktop activity in streaks, and YouTube
Music's missing personal-mixes shelf.

## Shared real WebPlayer session

The previous Android helper manufactured a client token after capturing only
an access token. Desktop captures both from the actual web player and learns
current persisted-query hashes. Mobile now does the same: a document-start
hook watches actual fetch/XHR token responses, request headers and a bounded
set of public loaded script bundles. Only Spotify origins can supply session
credentials. Handcrafted client-token requests are removed. WebView startup
uses the saved cookie, waits for it to be installed and blocks navigation away
from open.spotify.com. Real browser-captured bearer/client tokens are used
directly, as on desktop; explicitly anonymous token responses are rejected.
The separate public Web API profile endpoint is not a cookie-login gate.
Session expiry also respects the client token.

Canvas, Discovery and likes share one in-flight mint per cookie and serialize
other mints because Android WebViews share a cookie jar. Legacy saved sessions
are expired once and reminted without discarding their encrypted cookie. Live
query hashes are retained with the secure session. Requests use the same desktop
WebPlayer user agent; only the older protobuf Canvas fallback uses the iOS UA.
Auth failures/stale persisted queries refresh once. Logs record request status
and session readiness, never cookies or bearer/client-token values.

## New Spotify likes, from activation

Enabling the toggle requests **one newest like** as its cursor and imports
nothing. Later polls fetch only newer entries, oldest first, stopping at the
previous cursor. Updating a cookie retains that cursor; disabling and re-enabling
establishes a fresh baseline. The old historical-backfill policy is migrated by
seeding a baseline on its first new poll. Existing Favorites are never removed.

Matching local songs are liked idempotently. The cursor advances only past
verified matches; unresolved matches are retried up to three polls, like the
desktop batch handler. Simultaneous timestamps stay retryable. This is a watcher
for matching library songs: it does not implement desktop's separate outbound
Lokal-to-Spotify mirror, import old likes or download missing audio.

## Streaks across devices

Streak calculations now combine phone activity preferences, phone listening
history and the paired play journal. Desktop plays count even if the song is
not owned by the phone. Repeated plays or overlapping devices count one local
calendar day. Current streaks permit yesterday as the latest activity day;
best historical streaks feed milestone tiers so a later gap does not erase a
past achievement. Calendar-day ordinals handle month, year, leap-day and DST
boundaries; existing YYYYMMDD preference keys remain compatible. Explicitly
clearing streak data applies a history cutoff instead of restoring cleared days.

This uses activity already received through library/history sync; it cannot
reconstruct desktop days without any synced play event. Already synced history
is used immediately without copying songs or re-importing ownership records.

## YouTube Music personal mixes

The existing first horizontal cover shelf is retained. Mix parsing now handles
localized shelf names, a personal-mix browse endpoint independent of its label,
and responsive playlist cards. Home continuations stop at the actual personal
mix shelf rather than an earlier unrelated radio card. If no mixes arrive, the
section offers retry instead of silently vanishing. No fallback playlists are
invented or mislabeled as personal mixes.

Validation: focused Dart tests cover saved-session migration, shared refresh,
current query hashes, likes activation/cursor acknowledgement, historical streaks
and month/year transitions, localized playlist parsing and first horizontal
shelf placement. The exact bundled JS hook is exercised with fetch responses
and a non-Spotify-origin guard. The pinned AndroidX WebKit API was inspected.
No APK/CI build or live Spotify account was used; native WebView/network behavior
and actual Canvas coverage still need confirmation on an Android device.
