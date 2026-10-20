# テストケース一覧（RSpec）

Blog 機能の自動テストと [spec/](../spec/) の対応表です。Devise のログイン・登録フロー自体は対象外です。

## 実行方法

```bash
docker compose up -d
docker compose exec web bin/rails db:test:prepare
docker compose exec web bundle exec rspec
```

個別実行:

```bash
docker compose exec web bundle exec rspec spec/models/blog_spec.rb
docker compose exec web bundle exec rspec spec/requests/blogs_spec.rb
```

## モデル（Blog）— `spec/models/blog_spec.rb`

| ID | 前提 | 操作 | 期待結果 | 実装 |
|----|------|------|----------|------|
| TC-01 | なし | `create(:blog)` | DB に保存され `persisted?` が true | factory example |
| TC-02 | title なし | `build(:blog, title: nil).valid?` | invalid、title にエラー | validations |
| TC-03 | post なし | `build(:blog, post: nil).valid?` | invalid、post にエラー | validations |
| TC-04 | user なし | `build(:blog, user: nil).valid?` | invalid、user にエラー | validations |
| TC-05 | 保存済み Blog | `soft_delete!` | `deleted_at` 設定、`Blog.active` から除外 | soft_delete / active |
| TC-06 | なし | Factory で 2 件 create | `Blog.active.pluck(:title)` / `Blog.find` で取得できる | factory example |

スタブデータは **Factory Bot**（[`spec/factories/`](../spec/factories/)）で生成します。

## Request — `spec/requests/blogs_spec.rb`

| ID | 前提 | 操作 | 期待結果 | 実装 |
|----|------|------|----------|------|
| TC-R01 | Factory で Blog 1 件 | `GET /blogs` | 200、タイトルが HTML に含まれる | GET /blogs |
| TC-R02 | 同上 | `GET /blogs/:id` | 200、本文が HTML に含まれる | GET /blogs/:id |
| TC-R03 | Blog を論理削除済み | `GET /blogs/:id` | 404 | GET /blogs/:id |
| TC-R04 | 未ログイン | `GET /blogs/new` | 302、`/users/sign_in` へ | GET /blogs/new |

## スコープ外

- `POST /users/sign_in` など Devise 認証の成功・失敗
- ログイン後の `POST /blogs`（作成成功）
- System spec（Capybara）
