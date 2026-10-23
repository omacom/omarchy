from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
import json
import sys
import time

stage = Path(sys.argv[1])
log = stage.parent / 'network-urls'
log.write_text('')
scan_requests = 0


class Handler(BaseHTTPRequestHandler):
  def do_GET(self):
    global scan_requests
    with log.open('a') as stream:
      stream.write(self.path + '\n')
    if self.path.startswith('/nws/'):
      body = json.dumps({'properties': {'radarStation': 'KABX'}}).encode()
    elif self.path.startswith('/scans/'):
      scan_requests += 1
      if scan_requests > 1:
        time.sleep(10)
      body = json.dumps({'scans': [{'ts': '2026-10-23T00:00Z'}, {'ts': '2026-10-23T00:05Z'}]}).encode()
    else:
      body = (stage / 'weather/n0b-palette.png').read_bytes()
    self.send_response(200)
    self.send_header('Content-Length', str(len(body)))
    self.end_headers()
    self.wfile.write(body)

  def log_message(self, *args):
    pass


server = ThreadingHTTPServer(('127.0.0.1', 0), Handler)
(stage / 'port').write_text(str(server.server_port))
server.serve_forever()
