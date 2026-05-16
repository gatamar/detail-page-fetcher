from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
import json
from pathlib import Path
from urllib.parse import unquote, urlparse


HOST = "127.0.0.1"
PORT = 8000
ROOT = Path(__file__).parent
LIST_FILE = ROOT / "mathematicians-list.json"
DETAILS_FILE = ROOT / "mathematicians-details.json"


def read_json(path):
    with path.open(encoding="utf-8") as file:
        return json.load(file)


class Handler(BaseHTTPRequestHandler):
    def send_json(self, data, status=200):
        body = json.dumps(data, indent=2).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()
        self.wfile.write(body)

    def do_OPTIONS(self):
        self.send_response(204)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.end_headers()

    def do_GET(self):
        path = unquote(urlparse(self.path).path).strip("/")

        if path in ("", "health"):
            self.send_json(
                {
                    "ok": True,
                    "routes": [
                        "/mathematicians",
                        "/mathematicians/{id}",
                        "/mathematicians-list.json",
                        "/mathematicians-details.json",
                    ],
                }
            )
            return

        if path in ("mathematicians", "mathematicians-list.json"):
            self.send_json(read_json(LIST_FILE))
            return

        if path in ("mathematicians-details", "mathematicians-details.json"):
            self.send_json(read_json(DETAILS_FILE))
            return

        if path.startswith("mathematicians/"):
            person_id = path.removeprefix("mathematicians/")
            details = read_json(DETAILS_FILE)
            person = details.get(person_id)
            if person is None:
                self.send_json({"error": "Not found", "id": person_id}, status=404)
            else:
                self.send_json(person)
            return

        self.send_json({"error": "Not found", "path": self.path}, status=404)


if __name__ == "__main__":
    server = ThreadingHTTPServer((HOST, PORT), Handler)
    print(f"Serving JSON on http://{HOST}:{PORT}")
    print("Press Ctrl+C to stop.")
    server.serve_forever()
