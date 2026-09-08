#!/usr/bin/env python3
"""Create a deterministic nginx-ready archive; never include .git or source-only files."""
import gzip
import hashlib
import io
import json
from pathlib import Path
import tarfile
from build import build, ROOT, ALLOWED

build()
release = ROOT / 'release'
if release.is_symlink():
    raise SystemExit('Refusing symlinked release directory')
release.mkdir(exist_ok=True)
files = {f'dist/{name}': (ROOT / 'dist' / name).read_bytes() for name in ALLOWED}
files['nginx-site.conf.example'] = (ROOT / 'migration/nginx-site.conf.example').read_bytes()
manifest = {name: hashlib.sha256(data).hexdigest() for name, data in sorted(files.items())}
files['SHA256-MANIFEST.json'] = (json.dumps(manifest, indent=2) + '\n').encode()
archive = release / 'vibe-static.tar.gz'
if archive.is_symlink():
    raise SystemExit('Refusing symlinked archive')
with archive.open('wb') as raw, gzip.GzipFile(filename='', fileobj=raw, mode='wb', mtime=0) as gz:
    with tarfile.open(fileobj=gz, mode='w') as tar:
        for name, data in sorted(files.items()):
            info = tarfile.TarInfo(name)
            info.size, info.mode, info.mtime = len(data), 0o644, 0
            tar.addfile(info, io.BytesIO(data))
print(f'Archive: {archive}')
print(f'SHA256: {hashlib.sha256(archive.read_bytes()).hexdigest()}')
