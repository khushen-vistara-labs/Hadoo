"""Pre-publication boundary check; reports locations, never matched secret values.

Heuristic scan, not proof that arbitrary credentials are absent. Review staged
changes as well. Ignores untracked/ignored private material by using git's file list.
"""
import re
from pathlib import Path
import subprocess
import sys

RULES = {
    'private-key': re.compile(rb'-----BEGIN (?:RSA |EC |OPENSSH |DSA |ENCRYPTED )?PRIVATE KEY-----'),
    'github-token': re.compile(rb'\b(?:gh[pousr]_[A-Za-z0-9]{25,}|github_pat_[A-Za-z0-9_]{30,})\b'),
    'aws-access-key': re.compile(rb'\bAKIA[A-Z0-9]{16}\b'),
    'personal-local-path': re.compile(rb'(?:[A-Za-z]:[/\\]+Users[/\\]+(?!name\b|user\b|example\b|Public\b|Alice\b|test\b)[A-Za-z0-9][A-Za-z0-9_.-]*|/home/(?!user\b|runner\b|example\b)[A-Za-z0-9][A-Za-z0-9_.-]*|/mnt/c/Users/[A-Za-z0-9][A-Za-z0-9_.-]*)'),
}
BLOCKED_NAMES = {'key.properties', 'local.properties', '.env', '.env.local', 'signing.json'}
BLOCKED_SUFFIXES = {'.jks', '.keystore', '.p12', '.pfx', '.pem', '.apk', '.aab', '.log'}


def main():
    root = Path(__file__).resolve().parents[1]
    result = subprocess.check_output(
        ['git', 'ls-files', '-z', '--cached', '--others', '--exclude-standard'], cwd=root)
    paths = sorted(set(result.decode().split('\0')) - {''})
    findings = []
    total = 0
    for name in paths:
        path = root / name
        if not path.is_file():
            continue
        total += path.stat().st_size
        if path.name in BLOCKED_NAMES or path.suffix in BLOCKED_SUFFIXES:
            findings.append(f'{name}: forbidden publication artifact')
            continue
        if path.stat().st_size >= 100 * 1024 * 1024:
            findings.append(f'{name}: exceeds GitHub regular-file limit')
        data = path.read_bytes()
        if b'\0' in data[:8192]:
            continue
        for rule, pattern in RULES.items():
            for match in pattern.finditer(data):
                line = data.count(b'\n', 0, match.start()) + 1
                findings.append(f'{name}:{line}: {rule}')
    print(f'Publication candidates: {len(paths)} files, {total / 1024 / 1024:.1f} MiB')
    for finding in findings:
        print(finding)
    print(f'{len(findings)} finding(s); matched values intentionally omitted.')
    return bool(findings)


if __name__ == '__main__':
    sys.exit(main())
