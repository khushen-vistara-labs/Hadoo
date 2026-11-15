# Discord mobile SDK 1.10.19337

Public Hadoo builds leave this optional Discord SDK unstaged. If you are
authorized to use the SDK, follow the developer portal's distribution terms.
The optional staging script expects a private local
`discord-mobile-1.10.19337.zip.gpg` containing `include/discordpp.h`,
`lib/release/discord_partner_sdk.aar` and `License-Notices.txt`.

The decryption key belongs only in the repository Actions secret
`LOKAL_DISCORD_SDK_PASSPHRASE` (or a local environment variable). It is not
stored in this repository. Trusted beta/release builds run
`python3 tool/prepare_discord_sdk.py` to decrypt, verify the pinned file hashes
and stage native libraries plus required license notices. Plaintext staging is
ignored by Git. See `docs/DISCORD_PRESENCE.md` for setup.
