#!/usr/bin/env python3
"""Rebuild a public-only directory from an exact asset allowlist. No third-party packages."""
from pathlib import Path
import shutil
import tempfile
ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'dist'
ALLOWED = ['bny-ai.png', 'examples/ch1-hello-world.json', 'examples/ch2-schedule-trigger.json', 'examples/ch2-webhook-form.json', 'examples/ch3-http-request.json', 'examples/ch3-if-condition.json', 'examples/ch4-line-notify.json', 'examples/ch4-line-push.json', 'examples/ch4-weather-line-messaging.json', 'examples/ch4-weather-line.json', 'examples/ch6-final-project.json', 'index.html', 'mario.html', 'robots.txt', 'sitemap.xml']

def build():
    if OUT.is_symlink() or (OUT.exists() and not OUT.is_dir()):
        raise SystemExit('Refusing to replace a symlink or non-directory dist')
    # Validate all input before changing the generated output.
    for name in ALLOWED:
        source = ROOT / name
        if not source.is_file() or any(p.is_symlink() for p in (source, *source.parents) if p != ROOT and ROOT in p.parents):
            raise SystemExit(f'Missing or symlinked public asset: {name}')
    with tempfile.TemporaryDirectory(prefix='.build-', dir=ROOT) as temp:
        stage = Path(temp) / 'dist'
        stage.mkdir()
        for name in ALLOWED:
            dest = stage / name
            dest.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(ROOT / name, dest)
        # dist is generated, disposable output; stale files must never be published.
        if OUT.exists():
            shutil.rmtree(OUT)
        stage.rename(OUT)
    print(f'Public assets ready: {OUT}')

if __name__ == '__main__':
    build()
