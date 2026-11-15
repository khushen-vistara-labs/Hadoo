"""Decrypt and stage the pinned mobile SDK for trusted beta/release builds."""
import os
import shutil
from pathlib import Path
import subprocess
import tempfile
from zipfile import ZipFile

from setup_discord_sdk import FILES, stage

ROOT = Path(__file__).resolve().parents[1]
ARCHIVE = ROOT / 'third_party/discord/discord-mobile-1.10.19337.zip.gpg'


def prepare() -> None:
    key = os.environ.get('LOKAL_DISCORD_SDK_PASSPHRASE', '')
    if not key:
        raise ValueError('Set the LOKAL_DISCORD_SDK_PASSPHRASE repository Actions secret before building releases.')
    if '\n' in key or '\r' in key:
        raise ValueError('The Discord SDK passphrase must be a single line.')
    with tempfile.TemporaryDirectory(prefix='lokal-discord-') as temporary:
        work = Path(temporary)
        home = work / 'gnupg'
        home.mkdir(mode=0o700)
        decrypted = work / 'sdk.zip'
        # Pass the key through stdin, never command-line arguments or logs.
        env = {k: v for k, v in os.environ.items() if k != 'LOKAL_DISCORD_SDK_PASSPHRASE'}
        result = subprocess.run([
            'gpg', '--homedir', str(home), '--batch', '--yes',
            '--pinentry-mode', 'loopback', '--passphrase-fd', '0',
            '--output', str(decrypted), '--decrypt', str(ARCHIVE),
        ], input=(key + '\n').encode(), env=env, stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)
        if result.returncode:
            raise ValueError('Cannot decrypt Discord SDK; check LOKAL_DISCORD_SDK_PASSPHRASE.')
        source = work / 'source'
        with ZipFile(decrypted) as archive:
            # Only the three pinned SDK files are used. stage() verifies hashes.
            for relative in FILES:
                output = source / relative
                output.parent.mkdir(parents=True, exist_ok=True)
                with archive.open(relative) as original, output.open('wb') as destination:
                    shutil.copyfileobj(original, destination)
        stage(source)


if __name__ == '__main__':
    try:
        prepare()
    except (OSError, ValueError, KeyError) as error:
        raise SystemExit(str(error)) from error
