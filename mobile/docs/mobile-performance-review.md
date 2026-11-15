# Mobile playback and performance review

Scope: Xiaomi 17, Android 17, stock launcher, as reported by the user. The supplied
recording shows Cover Flow panels intersecting while both are still face-on.
This review is based on source inspection and that recording, not an on-device
CPU/GPU profile. No frame-rate or battery improvement has been measured yet.

## Rendering and memory

- Cover Flow rebuilt artwork and reflection subtrees on every animation tick.
  Its depth-sorted Stack also lacked album keys, so crossing the midpoint could
  transfer image state to a different album. Keep keyed, cached faces behind
  repaint boundaries; animate their transforms. Remove the reflected shadow.
- A linear near-cover translation let tilted panels intersect. Separate them
  earlier along a sine path, normalize perspective by cover size, and increase
  spacing behind the selected cover. Reduced motion uses a flat spaced row.
- Common artwork widgets could decode original multi-megapixel covers for tiny
  rows. Derive decode width from physical display size, bucket it to 64 pixels
  to share cache entries, and cap automatic decodes at 2048 pixels. Explicit
  thumbnail dimensions remain supported.
- Palette extraction leaked codec/image handles and retained unbounded color
  maps. Release sample handles and bound each result map to 128 entries.
- Ambient backgrounds retained every blurred raster for the session. Bound the
  shared cache to 12 300x300 rasters (about 4.1 MiB of RGBA storage, excluding
  active/outgoing images and engine overhead). Widgets own cloned handles so
  eviction cannot invalidate a visible cross-fade. Reject stale async results.
- Isolate the nested screen navigator's repaints from animated footer chrome.
  Artwork-color selection no longer depends on playback position ticks.

## Database and background work

- Every songs-table write invalidated the whole song list, querying, sorting
  and regrouping the library again. Reuse the shared 500 ms throttled revision
  instead, including its trailing notification for the final batch.
- Library filtering/sorting repeated during unrelated widget builds. Retain
  results until the song list, query, sort or play counts change.
- Connect the shell to the existing artwork scroll gate. Admit at most four
  deferred resolution callbacks after each frame when scrolling settles,
  instead of synchronously releasing the entire backlog.
- Android widget sync rewrote unchanged preferences and rebuilt all three
  widgets on position ticks. Serialize updates, coalesce to the latest state,
  save only changed fields, and refresh only the progress-bearing mini widget
  when position/duration alone change. Song/transport changes still refresh all.

## YouTube media handoff

Android already uses BitChord-derived InnerTubeX/cipher/PoToken extraction.
The downstream media path was different: it rejected WebM, refused media
redirects, advanced by the requested range size rather than the received size,
and swallowed foreground resolution errors as a silent skip.

Accept the WebM signature while retaining the mandatory native format probe.
Permit bounded redirects only within HTTPS googlevideo hosts, retain the exact
signed URL/client headers, validate range offsets, and advance by bytes received.
Keep 512 KiB/1 MiB client-specific range limits. Native Android resolution is now
one bounded 45-second operation instead of a native/direct/native retry chain;
a rejected signed-in extraction can retry publicly without changing the saved
account. Serialize extraction session changes. Playback failures reach the UI;
cancelled/superseded requests remain silent.

## Navigation and launcher

Desktop link is under Data. Shared top-bar padding, 44-pixel button rows and
large-title padding align Library, its subpages and Settings. Launcher aliases
apply when the saved accent arrives, with retries on startup/onStop; no reliance
on delayed OEM foreground-task teardown. Application/round-icon defaults use the
Lokal adaptive resource. OS-themed/monochrome icon recoloring remains controlled
by the launcher.

## Verification and remaining device checks

Focused Dart analysis and whitespace checks; analytical projection sweep across
1,001 transition positions and several cover sizes checks adjacent-panel
separation. No full APK build, CI run, Android runtime or live YouTube playback
verification was performed. Verify logged-in and guest YouTube playback, rapid
song changes, large merged libraries, Home/Cover Flow scrolling, player gestures,
widget progress and accent changes on the reported Xiaomi/launcher before
claiming the device-specific issues resolved or a measured speedup.
