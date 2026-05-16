# JSON Server

Tiny dependency-free Python server with 100 records across two JSON files:

- `mathematicians-list.json` has the list view data.
- `mathematicians-details.json` has the detail records keyed by `id`.

Run it from the repo root:

```sh
python3 json-server/server.py
```

Then fetch:

```sh
curl http://127.0.0.1:8000/mathematicians
curl http://127.0.0.1:8000/mathematicians/ada-lovelace
curl http://127.0.0.1:8000/mathematicians-details.json
```

Available routes:

- `GET /`
- `GET /health`
- `GET /mathematicians`
- `GET /mathematicians/{id}`
- `GET /mathematicians-list.json`
- `GET /mathematicians-details.json`
