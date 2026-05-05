# StyleX Local Fashion AI

This is the local demo backend for the StyleX iOS app. It mirrors the `fashion-ai`
API shape, but uses SQLite and deterministic demo logic so it runs reliably on a
Mac VM without Supabase, PyTorch, Gemini, or model downloads.

## Start on Mac or Mac VM

```bash
./scripts/start-local-ai.sh
```

The API runs at:

```text
http://127.0.0.1:8000
```

Interactive docs:

```text
http://127.0.0.1:8000/docs
```

## Demo endpoints

- `GET /`
- `GET /products`
- `POST /extract-features`
- `POST /get-recommendations`
- `POST /ai/recommend`
- `POST /embed-search-query`
- `POST /get-style-suggestion`
- `POST /ai/chat`

The SQLite file is created automatically at `LocalFashionAI/stylex_ai.sqlite3`.
Delete that file to reset the local demo catalog.
