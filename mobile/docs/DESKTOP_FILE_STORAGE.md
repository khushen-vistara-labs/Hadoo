# Desktop song files on Android

Desktop Link → Copy missing song files and a desktop song's Download action save
original audio under `Lokal Desktop` inside the first writable music folder
selected in Library settings. They do not use app-private storage as a permanent
fallback. If no folder is selected or access has expired, the operation reports
how to select the folder again.

Downloads use temporary staging while checking the response length/checksum and
probing actual audio quality. The verified file is copied into the chosen folder;
only then is the library row updated. Staging files are removed after success or
failure. Existing music is never overwritten. Android's persisted folder grant
is used when scoped storage blocks raw filesystem writes; those copies retain a
playable document URI and the selected folder association for future scans.

For songs already copied into private `desktop_music`, run **Copy missing song
files** again. The preview counts existing copies to recover separately from new
PC downloads. Recovery reads the phone file, saves it to the selected music
folder and updates the same library row, preserving IDs, likes, playlists,
listening history, artwork, quality fields and ID-keyed synced lyrics. It does not
re-download the audio. Original private files remain as recovery inputs so a
currently queued old path can continue to play; this change does not delete them.
A second copy check skips recovered rows because they now point into the music
folder.

Validation: six focused Dart/storage tests cover exact file bytes, preserved
metadata/identity, absent and revoked folder access, SAF URI persistence, database
failure rollback and filename collisions. Targeted Dart analysis has no errors.
The native SAF writer streams in 1 MiB chunks, checks length, renames the partial
file and cleans up a failed write. No APK/CI build or Android document-provider
hardware test was run for this change.
