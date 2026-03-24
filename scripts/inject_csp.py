#!/usr/bin/env python3
"""
Post-build script: inject Content-Security-Policy meta tag into build/web/index.html.

Usage:
    python3 scripts/inject_csp.py

Run this after `flutter build web --release`.
The source web/index.html intentionally has no CSP so that `flutter run`
(dev mode) works without errors. CSP is only applied to the production build.
"""

import hashlib
import base64
import re
import sys
from pathlib import Path

BUILD_INDEX = Path('build/web/index.html')

# CSP template. {hashes} is replaced with space-separated 'sha256-...' tokens.
CSP_TEMPLATE = (
    "default-src 'none'; "
    "script-src 'self' blob: {hashes} 'wasm-unsafe-eval' https://www.gstatic.com; "
    "worker-src 'self' blob:; "
    "style-src 'self' 'unsafe-inline'; "
    "img-src 'self' data: blob:; "
    "font-src 'self' data: https://fonts.gstatic.com; "
    "manifest-src 'self' blob:; "
    "connect-src 'self' https://www.gstatic.com https://fonts.gstatic.com; "
    "base-uri 'self'; "
    "form-action 'none'"
)


def sha256_hash(text: str) -> str:
    digest = hashlib.sha256(text.encode()).digest()
    return "'" + 'sha256-' + base64.b64encode(digest).decode() + "'"


def main():
    if not BUILD_INDEX.exists():
        print(f'Error: {BUILD_INDEX} not found. Run `flutter build web --release` first.')
        sys.exit(1)

    html = BUILD_INDEX.read_text(encoding='utf-8')

    # Compute hashes for all inline <script> blocks.
    scripts = re.findall(r'<script>(.*?)</script>', html, re.DOTALL)
    if not scripts:
        print('Warning: no inline <script> blocks found.')
    hashes = ' '.join(sha256_hash(s) for s in scripts)
    for i, s in enumerate(scripts):
        print(f'  block{i + 1}: {sha256_hash(s)}')

    csp = CSP_TEMPLATE.format(hashes=hashes)
    meta_tag = f'  <meta http-equiv="Content-Security-Policy" content="{csp}">\n'

    # Remove any existing CSP meta tag to avoid duplicates.
    html = re.sub(
        r'\s*<meta http-equiv="Content-Security-Policy"[^>]*>\n?',
        '',
        html,
    )

    # Insert before <base href (first occurrence).
    if '<base href' not in html:
        print('Error: <base href not found in build/web/index.html.')
        sys.exit(1)

    updated = html.replace('  <base href', meta_tag + '  <base href', 1)

    if updated == html:
        print('Error: failed to insert CSP meta tag.')
        sys.exit(1)

    BUILD_INDEX.write_text(updated, encoding='utf-8')
    print(f'CSP injected into {BUILD_INDEX}')


if __name__ == '__main__':
    main()
