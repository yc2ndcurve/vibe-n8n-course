#!/usr/bin/env python3
"""Build only explicitly allowed public assets; never copy .git or deployment files."""
from pathlib import Path
import shutil
ALLOWED = ['index.html', 'mario.html', 'robots.txt', 'sitemap.xml', 'bny-ai.png', 'examples']
ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'dist'
OUT.mkdir(exist_ok=True)
for name in ALLOWED:
    source = ROOT / name
    if source.is_dir():
        shutil.copytree(source, OUT / name, dirs_exist_ok=True)
    else:
        shutil.copy2(source, OUT / name)
print(f'Public assets ready: {OUT}')
