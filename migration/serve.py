#!/usr/bin/env python3
"""Local-only preview. Build first. Serves dist only, never repository metadata."""
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlsplit
import argparse
ROOT = Path(__file__).resolve().parents[1] / 'dist'
class Handler(SimpleHTTPRequestHandler):
    def route(self):
        path = urlsplit(self.path).path
        if path == '/':
            self.path = '/mario.html'
        elif not (ROOT / path.lstrip('/')).exists():
            self.path = '/mario.html'
    def do_GET(self):
        self.route()
        super().do_GET()
    def do_HEAD(self):
        self.route()
        super().do_HEAD()
p = argparse.ArgumentParser()
p.add_argument('--port', type=int, default=8082)
a = p.parse_args()
if not ROOT.is_dir():
    raise SystemExit('Run python3 migration/build.py first')
server = ThreadingHTTPServer(('127.0.0.1', a.port), partial(Handler, directory=str(ROOT)))
print(f'Preview: http://127.0.0.1:{a.port}', flush=True)
server.serve_forever()
