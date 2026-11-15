# Fullscreen Canvas clear view

With fullscreen covers enabled and a Spotify Canvas actually loaded, tap unused
player space to fade controls and contrast out; tap again to restore them.
Buttons retain their own actions. Horizontal song swipes remain enabled and
restore controls as the swipe starts; song changes also restore controls and
invalidate the previous song's Canvas readiness. Queue/lyrics restore the UI.
The existing artwork morph and shared decoder remain in use.

Disabling motion for a song removes the fullscreen video subtree and explicitly
renders its still-cover frame, avoiding a retained video texture over the poster.
The saved motion preference is unchanged for other songs.

No tests or APK builds were run, as requested. Device verification is pending.
