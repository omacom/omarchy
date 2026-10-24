from datetime import date, timedelta
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
import json
import sys

stage = Path(sys.argv[1])
log = stage.parent / 'behavior-urls'
log.write_text('')


class Handler(BaseHTTPRequestHandler):
  def do_GET(self):
    with log.open('a') as stream:
      stream.write(self.path + '\n')
    if self.path.startswith('/wttr/'):
      body = json.dumps({'nearest_area': [{'latitude': '39.7392', 'longitude': '-104.9903', 'areaName': [{'value': 'Denver'}]}], 'current_condition': [{'temp_C': '20', 'weatherCode': '113'}]}).encode()
    elif self.path.startswith('/forecast'):
      body = json.dumps({'daily': {'time': [(date.today() + timedelta(days=i)).isoformat() for i in range(4)], 'weather_code': [0] * 4, 'temperature_2m_max': [21] * 4, 'temperature_2m_min': [12] * 4}}).encode()
    elif self.path.startswith('/geo'):
      body = b'{}'
    elif self.path.startswith('/nws/'):
      body = b'{"properties":{"radarStation":"KFTG"}}'
    elif self.path.startswith('/scans/'):
      body = b'{"scans":[{"ts":"2026-10-23T00:00Z"},{"ts":"2026-10-23T00:05Z"}]}'
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
