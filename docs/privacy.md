# Privacy and data

Hadoo stores its library, downloads, listening history, likes, settings, and **Hadoo playlists** on your device. Hadoo has no account system of its own and includes no advertising SDK or product analytics. Device backups and exports can contain app data.

A saved profile username does not synchronize those files or playlists. The current distributed builds do not have configured Google Drive playlist sync. YouTube account playlists remain separate and synchronize through YouTube Music.

## Online features

- YouTube Music receives guest search and playback requests. When signed in, it also receives requests for your recommendations and playlists. Creating or editing a **YouTube playlist** sends the change to YouTube. Hadoo can cache playlist metadata on the device for browsing.
- Enabled providers and add-ons receive the requests needed for search, playback, downloads, account connections, or optional scrobbling. Providers may see your IP address, search terms, and request details. Each service applies its own privacy terms.
- Optional lyrics and artwork lookups can send track title, artist, and album to services such as LRCLIB and Apple. Update checks can contact GitHub or the applicable store.
- Account sessions are stored on the device. Use the account screen to sign out and remove the saved session for that service. AltStore and Xcode signing happen outside Hadoo.

Apple Account authentication used by AltStore, AltServer, or Xcode is for iPhone signing, not a Hadoo login. Enter Apple credentials only in those tools' own authentication prompts. Android installation uses the APK's signing certificate and does not require an Apple Account. [Installation and renewal](device-setup.md)

Grant storage access for the folders you choose to use. Enable third-party add-ons, servers, or sharing features only when you intend to use them. Playback and source diagnostics are stored locally and can be exported if you choose to share them.

See [Troubleshooting](troubleshooting.md#report-a-problem) for what to include in a public bug report.
