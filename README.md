# rails8_blog_app
tech stack

* ruby v3
* rails v8
* postgresql v17

## UI
* BootStrap
* CSS

## Master Data
3 data

* Blog model
* id, title, post, created_at, updated_at, deleted_at, timestamp

## Auth
* Devise（メール + パスワード）。開発用デモ: `demo@example.com` と `.env` の `DEMO_USER_PASSWORD`（本番禁止）

## Docker (Hello World)

```bash
cp .env.example .env
docker compose up -d --build
```

## Blog チュートリアル（手作業・1 コミットずつ）

[docs/blog_tutorial.md](docs/blog_tutorial.md)

## Devise チュートリアル（Blog 所有者）

[docs/devise_tutorial.md](docs/devise_tutorial.md)