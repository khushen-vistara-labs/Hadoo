"""Create a private release identity and upload it through gh's encrypted secrets API.

Run only when authorized to create/configure the application's signing identity.
No secret values are printed or written inside the source checkout.
"""
import argparse
import base64
import json
import os
from pathlib import Path
import secrets
import subprocess


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--directory', type=Path, required=True)
    parser.add_argument('--keytool', required=True)
    parser.add_argument('--repo', required=True)
    parser.add_argument('--upload', action='store_true')
    args = parser.parse_args()
    directory = args.directory.expanduser().resolve()
    repository = Path(__file__).resolve().parents[1]
    if directory == repository or repository in directory.parents:
        raise ValueError('Signing directory must be outside the source repository')
    if directory.exists():
        raise ValueError('Refusing to overwrite an existing signing identity')
    os.umask(0o077)
    directory.mkdir(parents=True, mode=0o700)
    password = secrets.token_urlsafe(48)
    alias = 'konnekted2'
    keystore = directory / 'konnekted2-release.jks'
    env = dict(os.environ, KONNEKTED_STORE_PASS=password, KONNEKTED_KEY_PASS=password)
    subprocess.run([
        args.keytool, '-genkeypair', '-keystore', str(keystore),
        '-storetype', 'JKS', '-alias', alias, '-keyalg', 'RSA', '-keysize', '4096',
        '-sigalg', 'SHA256withRSA', '-validity', '10000',
        '-dname', 'CN=Konnekted2, OU=Android, O=Lokal-Konnekt',
        '-storepass:env', 'KONNEKTED_STORE_PASS', '-keypass:env', 'KONNEKTED_KEY_PASS',
        '-noprompt',
    ], env=env, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    keystore.chmod(0o600)
    record = directory / 'signing.json'
    record.write_text(json.dumps({
        'keystore': keystore.name,
        'alias': alias,
        'store_password': password,
        'key_password': password,
        'repository': args.repo,
    }, indent=2) + '\n')
    record.chmod(0o600)
    if args.upload:
        values = {
            'ANDROID_KEYSTORE_BASE64': base64.b64encode(keystore.read_bytes()).decode('ascii'),
            'ANDROID_KEYSTORE_PASSWORD': password,
            'ANDROID_KEY_ALIAS': alias,
            'ANDROID_KEY_PASSWORD': password,
        }
        for name, value in values.items():
            subprocess.run(['gh', 'secret', 'set', name, '--repo', args.repo],
                           input=value, text=True, check=True,
                           stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        print('Configured all four GitHub release signing secrets.')
    print(f'Private signing identity created at: {directory}')
    print('Back up BOTH files in an encrypted location; losing this key prevents compatible updates.')


if __name__ == '__main__':
    try:
        main()
    except (OSError, ValueError, subprocess.CalledProcessError) as error:
        if isinstance(error, ValueError):
            raise SystemExit(str(error)) from None
        raise SystemExit('Signing setup failed. Preserve any existing private files; no secrets were printed.') from None
