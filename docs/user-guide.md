# Use Hadoo

## Start listening

1. On first launch, tap **Start listening**. You can begin as a guest.
2. Open **Search**, type a song or artist, and use **Songs**, **Videos**, or **Playlists** to narrow the results. Choose the result type and source you want. Tap a song to play audio. The Videos tab opens video results.
3. Open the mini-player for the full controls, queue, and lyrics when available.

For personal YouTube recommendations and saved playlists, open **Settings → Data → Accounts** and connect **YouTube Music**. After sign-in, Home uses that account's recommendations. Pull down to refresh the feed or playlist list if you just made changes on YouTube.

## Choose a playlist type

Open **Library → Playlists**, use the new-playlist action, and choose the destination. You can also create one from a track's **Add to playlist** menu.

| Playlist type | What it stores | Where it appears |
| --- | --- | --- |
| **Hadoo playlist** | Local files and eligible tracks from multiple sources, including external add-ons | In Hadoo on this phone |
| **YouTube playlist** | YouTube Music recording IDs. New playlists are private and edits sync to the signed-in account | In Hadoo and in YouTube Music |

Use the same YouTube account on two phones to access its YouTube playlists. **Hadoo playlists, downloads, local files, likes, and a saved profile username do not become a cloud account.** The Google Drive playlist-sync work is not configured in the current distributed builds. An unavailable-sync message does not affect local playlists or YouTube playlist access. See [platform status](mobile-rewrite.md) for what has actually shipped.

Later local Android previews add a direct **New Hadoo playlist** action to Library. If your build lacks that action, create a Hadoo playlist from a track's **Add to playlist** picker.

To add a song, open its **⋯ → Add to playlist** menu. Choose **Hadoo playlists** for a recording that only exists on another source. If a result has a YouTube recording ID, it can also be eligible for a YouTube playlist. Hadoo checks for an existing copy when adding a YouTube recording and reports duplicates. YouTube writes need a live account session and a server response. Playlist entries point to recordings. Download eligible recordings separately for offline listening.

## Pick your sources

Open **Settings → Online sources** to enable optional providers or add your own.

- **YouTube Music** is the built-in catalogue for songs, playlists, and account recommendations. Public audio can play with a guest session.
- **Monochrome** searches a separate lossless catalogue. **SoundCloud** searches SoundCloud's catalogue. Availability, audio formats, and download eligibility vary by recording. Keep these sources enabled if you want Hadoo to consider them where an exact alternate recording is available.
- **HTTP music add-ons** and compatible add-on repositories can supply additional catalogues, including Amazon Music or JioSaavn when a compatible source is configured. Use the HTTPS manifest link from the add-on publisher and follow that source's sign-in instructions if required.
- **Global search catalogue** chooses Apple Music or Spotify **metadata** for Global results. Playback uses the **Playback search priority** list and the enabled sources. A catalogue result can appear even when none of your sources can play it.

## Download and play offline

1. Open a song's **⋯** menu and choose **Download** when available. Wait for it to finish.
2. Open **Downloads** from Home. Tap the saved track to play it. If you plan to travel, try opening it once in airplane mode before leaving.
3. Manage saved tracks from Downloads. Local file imports and optional network libraries are available in Settings.

For a playlist or collection download, **Downloaded** counts new files saved in that run. **Skipped** includes recordings already saved locally and duplicate entries; it is not a failure count. **Unavailable** or **Failed** reports entries the run could not save. Stopping and retrying retains completed files and checks for existing copies. For example, `Downloaded 0 · Skipped 130 · Unavailable 0` can mean all 130 entries were already available. Check the Downloads list and play its local entry to confirm.

Each phone downloads its own audio. Signing into the same YouTube account or seeing the same playlist on another phone does not copy downloaded files there.

### Offline lyrics

Hadoo can read lyrics embedded in an audio file, a manually selected lyrics file, or a matching `.lrc`/`.elrc` file saved beside the audio. Downloads attempt an online lyrics lookup and save available lyrics, but missing lyrics or a provider timeout does not block saving the audio. Audio downloaded successfully is not a guarantee that lyrics were found. Test the saved song in airplane mode before relying on its lyrics offline. New online lyrics searches and translation requests need a connection.

Streaming rights, preview-only results, and provider responses affect what can be saved. Only download content you have permission to keep. A song in a playlist may still need an internet connection unless you downloaded it.

## Now Playing

Tap **Queue** or swipe up in Now Playing to open the full queue page. Press Back or tap the current song to return to the player. Hold an upcoming song and drag it to change the order.

Open **Lyrics** to see the lyrics above the playback controls. The toolbar keeps save, source selection, translation, romanization, and search accessible. **Space** is available when the lyrics have synchronized timing.

On Android, standard playback uses the phone’s media volume buttons for USB headphones. If you want exclusive USB, choose it under **Settings → Advanced output → USB DAC**. **Auto Bit-perfect for USB DACs** is off unless you turn it on.

## In the car

Connect the phone to a compatible **Android Auto** head unit. For a trusted locally built preview, the car launcher may require enabling Android Auto's developer option for unknown sources. Open Hadoo in the car launcher for **Offline**, **Library**, **Liked songs**, or **Playlists**. Voice search currently searches saved library tracks. Configure Android Auto before driving. [Android Auto setup for test builds](https://developer.android.com/training/cars/testing#test-in-real-vehicles)

Android Auto uses the car's media browsing and Now Playing controls. Hadoo's phone lyrics screen is not exposed as an Android Auto lyrics view. Saved audio can play offline; new online catalogue requests still need the phone's connection.

A build signed with an approved **CarPlay** audio entitlement can show the same sections and Now Playing. The ordinary iPhone preview uses phone playback and can send audio over Bluetooth. [CarPlay build requirements](build.md#carplay)

See [platform status](mobile-rewrite.md) for device testing and remaining car checks.

For a head unit that runs Android apps itself, use the [standalone head-unit installation steps](device-setup.md#android-head-units-and-android-auto). Installing an APK on that unit and connecting a phone through Android Auto are separate installation routes.
