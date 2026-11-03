#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-only
"""Keep the repository's existing Conventional Commits convention."""
from pathlib import Path
import re
import sys

subject = Path(sys.argv[1]).read_text(encoding="utf-8").splitlines()[0]
if not re.match(r"^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\([^)]+\))?!?: .+", subject):
    raise SystemExit("Use a Conventional Commit subject, for example: feat(build): add Hadoo branding")
