# T3: opt-in online discovery

## Shell integration

The old standalone Discovery search/settings screen has been removed. New Search
is `package:flick/features/search/screens/search_screen.dart`; its online results
use the canonical `Settings → Online sources → HTTP music add-ons` editor and the
same secure `DiscoverySettingsStore` record. The guest catalog and HTTP add-on
search/playback paths continue to use the existing `http`, secure storage,
path_provider, crypto, path and url_launcher dependencies.

## Account Discovery (Konnekted Home)

YouTube Music account Discovery is a separate, opt-in path from the guest catalog
search described below. The user explicitly signs in from Integrations or from
the YouTube Music source chip on Home's Discovery tab. Its cookies and Innertube
page context are stored with FlutterSecureStorage; they are not written to
SharedPreferences or source code. The source selector is saved as
`lokal_discovery_source`, but account credentials remain in secure storage.

The account client requests the signed-in Likes (`VLLM`), Home
(`FEmusic_home`) and History (`FEmusic_history`) pages, follows bounded
continuations and presents provider-native mixes, Likes, history, artists and
Fresh Finds. Saved account tracks keep their video ID and known duration so
playback can resolve the exact recording without a title search. Mix playback
stages a bounded first batch of tracks; inaccessible recordings are skipped.
Spotify remains a placeholder and does not make network requests.

This is an unofficial, changeable Innertube interface. Google may refuse
embedded-browser sign-in or later invalidate cookies / alter response formats.
The account sign-in and authenticated calls need real-device validation; a
unit test of request signing does not prove Google will accept the session.
Signing out clears the stored app session and WebView cookies. The account
cookies are credentials: do not copy them into logs, reports or issues.

## What works

* All sources default off. Opening discovery makes no HTTP requests. Enabling a
  source and searching explicitly shares the query with that source; testing an
  endpoint explicitly contacts that endpoint even before it is enabled.
* Guest YouTube Music song search uses HTTPS Innertube `WEB_REMIX`, songs filter
  `EgWKAQIIAWoKEAkQChAFEAMQBA==`, with no cookies/account credentials. It extracts
  actual title, artist, album, duration and video ID from returned responsive
  rows, de-duplicates, and shows up to 50 results. The action opens the canonical
  `https://music.youtube.com/watch?v=...` in an external app/browser. No YouTube
  audio extraction, authentication or lossless claim is presented.
* Up to eight named listener-configured HTTPS addons can search and resolve their
  authorized audio. Add/edit/remove, enable switches and accessible up/down
  controls remain draft-only until Save sources succeeds. Search requests run
  concurrently; results retain saved addon order, followed by the guest catalog.
  Selecting a result checks its manifest, resolves a progressive audio URL,
  downloads a bounded temporary file, inspects its header, calls the **existing
  native `audioProbeFormat`**, builds a real `Song`, and invokes
  **`PlayerService().play(song, playlist: [song])`**. Existing queued entries are
  handled by PlayerService. No synthetic production tracks are supplied.
* Search is debounced 400 ms. Each edit, clear, configuration change and disposal
  invalidates older results/errors immediately. Independent source errors do not
  discard successful results from the other source. Empty, loading, access
  denied, malformed response, timeout and retry states are shown.
* The version-2 settings record is stored with existing FlutterSecureStorage in
  the stable `konnekted.discovery.sources.v1` slot, including endpoint paths, which may contain
  addon secrets. Editing an endpoint clears its bearer token to avoid carrying
  credentials to a newly selected server. Nothing is stored in source code or
  shared preferences. Settings are only applied after secure persistence succeeds.
  Version-1 single-addon records load with a stable `legacy-addon` identity,
  preserving enabled/disabled state and credentials; the next explicit save
  writes version 2. Invalid/unknown schemas fail closed without an automatic write.
* Results carry a local configuration ID and normalized endpoint, not an identity
  supplied by a server. Playback uses only that enabled source's credentials.
  Disabled, deleted, replaced or endpoint-edited source rows fail before making a
  request. Equal track IDs across addons remain distinct. Reordering changes
  presentation only: **automatic cross-source matching/fallback is not implemented**.

## Addon protocol (supported reference subset)

This is based on the original Konnekted
`app/.../data/sources/addon/AddonClient.kt` and `AddonModels.kt`. Catalog parsing
uses the shared `data/innertube/Innertube.kt`, `InnertubeParser.kt` and songs filter
as protocol references. This Dart adapter intentionally implements the small
progressive-audio subset below, not downloaded JS modules or provider pools.

The listener enters a base such as `https://their-server.example/music`, or its
`/manifest.json` URL. These are **protocol examples**, not bundled providers.
HTTPS with normal certificate verification is required. Endpoint user-info,
query, fragment, control characters and dot path segments are rejected. A path
credential is supported and secured with the rest of the settings.

If supplied, the optional token is sent as `Authorization: Bearer <token>` only
on these API requests. Only validated, locally saved manifest select settings are forwarded as query
parameters on search and stream requests; no arbitrary cookie passthrough exists.

### 1. Health: `GET {base}/manifest.json`

```json
{
  "id": "my-authorized-library",
  "name": "My music library",
  "resources": ["search", "stream"],
  "allowDownloads": true,
  "settings": [
    {"key": "quality", "default": "LOSSLESS",
     "options": [{"value": "LOSSLESS"}, {"value": "HI_RES"}, {"value": "HIGH"}]}
  ]
}
```

Requires a nonempty string `id` and both declared resources. `name` is optional.
The manifest's safe, human-readable `name` is used as the source label (rather
than the host or credential-bearing path). Manifest select settings are shown
under the source's settings button; the chosen values are stored securely and
sent as URL query parameters to both `/search` and `/stream/{id}`. Existing
saved sources can open that button to discover newly declared settings.

Health means the manifest was reachable and the resources were declared; it
does not claim that every search or audio download will succeed. An absent
`allowDownloads` uses the reference protocol default of true. Only true, 1,
`"true"`, `"1"` or absence permit temporary caching; other values block playback.
The manifest is rechecked on every playback attempt, including inline URLs.

### 2. Search: `GET {base}/search?q={encoded query}`

```json
{
  "tracks": [
    {
      "id": "library/recording-123",
      "title": "Recording title",
      "artist": "Artist name",
      "album": "Album name",
      "duration": 241.5,
      "sourceURL": "https://their-catalog.example/recordings/123"
    }
  ]
}
```

`tracks` must be an array, including for no matches (`[]`). String `id` and
`title` are required per usable row. Other fields are optional; duration is in
seconds. Malformed rows are skipped, duplicate IDs collapsed, and at most 50
results shown from the first 500 entries. A nonempty array with no usable rows
is an error. `sourceURL` is an optional adapter extension for the canonical
source page; supply a public, non-secret URL. It is metadata, not a local file.
Optional HTTPS `artworkURL` or `albumArtworkURL` metadata is propagated from
search into the downloaded Song: the bounded image fetch saves the cover
beside cached audio so the main player and notification can display it.
Untrusted/non-HTTPS artwork is skipped without interrupting search or playback.

An optional `streamURL` on a search row skips the stream lookup; all accompanying
transport/encryption/header flags are retained and validated. For short-lived
URLs prefer the `/stream/{id}` endpoint so every play resolves fresh media.

### 3. Resolve: `GET {base}/stream/{encoded track ID}`

```json
{
  "url": "https://their-cdn.example/audio/123?signature=short-lived-value",
  "encrypted": false,
  "manifest": "none"
}
```

The track ID is one encoded path segment; it cannot add URL query parameters.
Tracks from another configured endpoint cannot be resolved. Responses need an
absolute HTTPS `url`. An API `error`, encryption/DRM, nonempty custom `headers`,
HLS/DASH transport or playlist extension is rejected. Absent or boolean false
`encrypted`/`drm` is accepted; other values fail closed. `manifest`, `mediaType`,
`format`, `container`, `containerFormat` and `mimeType` are checked for unsupported
transport. Provider quality/sample-rate/bit-depth claims are never used as
verified playback metadata. The server receives the chosen valid manifest quality value when configured;
otherwise it uses its default.

Media requests have **no addon Authorization header**, even to the same host.
Use a short-lived signed media URL if authentication is needed. Neither API nor
media redirects are followed; provide final HTTPS addresses. Errors display
status categories rather than remote bodies or exception strings that may
contain credentials. Third-party CDN HTTPS hostnames are allowed, but unrelated
IP literals and obvious local hostnames are rejected. An explicitly configured
LAN HTTPS origin may serve its own media, on the same origin only. This is URL
validation, **not DNS/IP pinning**: it does not claim protection against a
configured malicious server using public DNS names that resolve privately.

## Playback and resource boundaries

PlayerService's reliable HTTP path resolves registered network-server songs
through RemoteSourceService. An arbitrary `sourceType` would enter that resolver
without a registered server, while a plain URL in `filePath` is not a reliable
cross-engine interface. Therefore this adapter stages a real local file.

* API JSON: 2 MiB maximum, 15-second absolute deadline, HTTP 200 only, no redirects.
  Oversized JSON is reported separately from oversized media to identify the
  failing stage without exposing add-on response bodies.
* Media: streamed to disk with backpressure, 512 MiB maximum per file, six-minute
  absolute deadline. Declared **and actual** body size are bounded. Empty,
  incomplete, oversized, cancelled or failed downloads are removed.
* Cache: `<application-cache>/discovery_audio`, 1 GiB cap, capacity reserved
  before download. Eviction is oldest-first and protects current, explicitly
  queued and up-next files exposed by PlayerService. If they consume the budget,
  the request fails instead of deleting those files. The UI serializes preparation.
  A new selection re-resolves/re-downloads; this is staging, not an offline library.
* Header recognition: FLAC, RIFF/WAVE, Ogg, ISO-BMFF/M4A, MP3. The header only
  selects the extension. Native format probing is mandatory (15-second wait
  limit); an HTML/JSON/playlist response is never handed to the engine. A
  plausible header that fails native probing also fails playback preparation.
* Actual probed sample rate is supplied to `Song`. Only FLAC's native-reported
  source bit depth is retained. Lossy decoder output widths are not advertised
  as source bit depth. `resolution` stays unset. The output route still determines
  whether Android mixing, DSP or resampling occurs; this feature makes no
  bit-perfect, USB or lossless-output claim.
* `Song.filePath` is strictly the local cached file. The canonical source URL
  stays a URL in `DiscoveryTrack.sourceUrl` and `Song.remoteId` (or the original
  addon ID if absent). `sourceType` stays null to avoid unsupported remote-server
  routing. `sourcePackage` is `konnekted.discovery`, with `isExternal: true`.
  Signed resolved media URLs stay in memory and are not put into the player queue.
* Cancel/dispose stops preparation and prevents subsequent resolve/download
  requests and handoff. Once handed to PlayerService, playback belongs to the
  ordinary player controls; leaving discovery does not stop it. PlayerService
  currently absorbs some startup exceptions, so UI checks its observable state
  rather than equating a completed Future with successful playback.

## Checks and remaining integration limits

Run from the project root with the supplied Windows Flutter SDK:

```text
flutter analyze --no-pub lib/features/discovery test/discovery
flutter test --no-pub test/discovery
flutter test --no-pub --dart-define=DISCOVERY_LIVE_TEST=true test/discovery/discovery_live_test.dart
```

The multi-addon follow-up adds 43 checks for migration, ordered search, credential
isolation, stale-row refusal, settings editing and saved opt-out integration.
The focused combined run (Spotify, playlist links, Flow, discovery, shell,
localization source guard, sharing and picked lyrics) completed with **143
passed, 1 skipped** after the Android dependency migration. The skip is the
explicitly gated live test.
The opt-in live guest catalog smoke test **passed** during implementation on
2026-10-13 for “Beethoven Moonlight Sonata”. The ordinary suite skips live
traffic. Innertube is an unofficial, changeable endpoint; consent, region,
network policy or future renderer/client-version changes can cause real errors.
The app displays those errors instead of substituting fake results.

MockClient tests exercise request shape, parsers, manifest/search/resolve,
credentials/URL boundaries, cancellation, absolute timeouts, response size,
debounce/stale results, secure-setting round trip, default-off UI, cache eviction,
probe failure and source-versus-file provenance. Unit cache tests inject the
native probe and **do not establish real decoder or audio-device operation**.

No real listener-owned addon endpoint or Android device was provided. End-to-end
addon playback on the native engine remains a device validation step: configure
an authorized addon with the above protocol, test its manifest, search and play
a supported recording, and verify player/output behavior. AAC/Opus support
depends on the shipped native build; even if Android could decode a file, this
adapter refuses it if the native probe cannot verify it. No DRM, HLS/DASH, account
auth, YouTube stream extraction, source-page-to-addon matching or community
Tidal/third-party-provider fallback is implemented or promised.

See `docs/BUILD.md` for current full-app build evidence and native prerequisites.
