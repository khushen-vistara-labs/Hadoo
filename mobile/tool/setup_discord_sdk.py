"""Stage Discord Social SDK 1.10.19337 downloaded from the Developer Portal.

Usage: python3 tool/setup_discord_sdk.py /path/to/extracted/discord_social_sdk
Unencrypted SDK binaries, secrets and local SDK paths are never committed.
"""
from hashlib import sha256
from pathlib import Path
import shutil
import sys
import tempfile
from zipfile import ZipFile

FILES = {
    'include/discordpp.h': '822e71509bf11b7155becca5fb00d215a7db7b305f357c0f3b5f6e27ff45b6ab',
    'lib/release/discord_partner_sdk.aar': 'b1b2491f1e1848c79fd6f1986d5aa1e0c8019e88a6e62c7be06b89e8e4870933',
    'License-Notices.txt': 'e8afa66340c225431e69768543cc34a7240f3494a9d759189fe118620ea8eebf',
}


def stage(source: Path) -> None:
    # Pinned to the version Mornye's bridge targets. Reassess the bridge when
    # upgrading instead of silently compiling against a different SDK API.
    for relative, expected in FILES.items():
        file = source / relative
        if not file.is_file() or sha256(file.read_bytes()).hexdigest() != expected:
            raise ValueError(f'Missing or incompatible SDK 1.10.19337 file: {relative}')
    parent = Path(__file__).resolve().parents[1] / 'third_party/mornye_discord'
    with tempfile.TemporaryDirectory(prefix='discord-stage-', dir=parent) as temporary:
        staged = Path(temporary) / 'sdk'
        staged.mkdir()
        aar = staged / 'discord_partner_sdk.aar'
        shutil.copyfile(source / 'lib/release/discord_partner_sdk.aar', aar)
        android = staged / 'android'
        with ZipFile(aar) as archive:
            for name in archive.namelist():
                if not (android / name).resolve().is_relative_to(android.resolve()):
                    raise ValueError('Unsafe SDK archive path')
            archive.extractall(android)
        header = android / 'prefab/modules/discord_partner_sdk/include/discordpp.h'
        header.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(source / 'include/discordpp.h', header)
        if not (android / 'jni/arm64-v8a/libdiscord_partner_sdk.so').is_file():
            raise ValueError('SDK is missing Android arm64-v8a')
        notices = staged / 'notices'
        notices.mkdir()
        shutil.copyfile(source / 'License-Notices.txt', notices / 'Discord-License-Notices.txt')
        target = parent / 'sdk'
        if target.exists():
            shutil.rmtree(target)
        shutil.move(staged, target)
    print('Discord SDK staged with notices. Rebuild Lokal to enable Discord presence.')


if __name__ == '__main__':
    if len(sys.argv) != 2:
        raise SystemExit(__doc__)
    try:
        stage(Path(sys.argv[1]).expanduser().resolve())
    except (OSError, ValueError) as error:
        raise SystemExit(str(error)) from error
