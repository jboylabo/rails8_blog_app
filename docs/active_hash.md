# ActiveHash

[active_hash](https://github.com/active-hash/active_hash) は、Ruby の Hash（または YAML / JSON）を読み取り専用のデータ源にする gem です。テーブルを作らず、Active Record に近い API（`all` / `find` / `where` / `belongs_to`）でマスタを扱えます。

このアプリの `Blog` と `User` は PostgreSQL 上の Active Record です。件数の少ない固定マスタ（カテゴリ、公開状態など）を DB に置かず、コード上のモデルとして持つのに向きます。

## ファイルの置き場所

| 種類 | パス | 理由 |
|------|------|------|
| この解説 | `docs/active_hash.md` | `docs/blog_tutorial.md` や `docs/devise_tutorial.md` と同じディレクトリ。ファイル名は gem 名 |
| gem 宣言 | `Gemfile` | `devise` と同じ本番グループ |
| モデル | `app/models/category.rb` など | Zeitwerk が `app/models` を自動読み込みする。`ApplicationRecord` は継承しない |
| YAML にする場合 | `app/models/categories.yml` | `ActiveYaml::Base` の既定は、モデルファイルと同じディレクトリの複数形 `.yml` |
| 既存モデルからの参照カラム | `db/migrate/..._add_category_id_to_blogs.rb` | 保存するのは整数 ID だけ。参照先テーブルはないので外部キー制約は付けない |

## 導入

```ruby
# Gemfile
gem "active_hash"
```

```bash
docker compose run --rm web bundle add active_hash
```

4 系は Ruby 3.0 以上、Rails 6.1 以上です。このアプリ（Ruby 3 / Rails 8.1）はそのまま使えます。

## モデル

```ruby
# app/models/category.rb
class Category < ActiveHash::Base
  self.data = [
    { id: 1, name: "技術" },
    { id: 2, name: "日記" }
  ]
end
```

```ruby
Category.all                 # 全件
Category.find(1)             # id で取得
Category.find_by(name: "技術")
Category.where(name: "日記")
```

`id` は、Active Record 側の外部キーに保存する値です。後から同じ ID のまま Active Record のテーブルへ移しても、参照側のカラムを変えずに済みます。

データ定義をクラスの外（initializer）に置く場合は、開発中の再読み込みで消えないように `to_prepare` に入れます。

```ruby
# config/initializers/active_hash.rb
Rails.application.config.to_prepare do
  Category.data = [
    { id: 1, name: "技術" },
    { id: 2, name: "日記" }
  ]
end
```

クラス本体に `self.data` を書くなら、この initializer は不要です。

## Blog から参照する

`blogs.category_id`（integer）を追加したうえで、関連は `Blog` ごとに拡張します。`ApplicationRecord` へは広げません。

```ruby
class Blog < ApplicationRecord
  extend ActiveHash::Associations::ActiveRecordExtensions

  belongs_to :user
  belongs_to :category
end
```

`blog.category` は `Category.find(blog.category_id)` と同じです。フォームでは次のように書けます。

```erb
<%= f.collection_select :category_id, Category.all, :id, :name %>
```

逆に ActiveHash から記事を辿るときは `ActiveHash::Associations` を include して `has_many :blogs` を定義します。Active Record の子として ActiveHash を持つ関連はサポートされていません。

## 操作方法

### 再起動が必要か

| 変更内容 | 開発環境（`docker compose up`） | 本番 |
|----------|-------------------------------|------|
| `category.rb` の `self.data` を編集 | 不要。`enable_reloading = true` で次のリクエストから反映される。`rails console` は開いたままなら `reload!` | デプロイ（再起動）が必要 |
| マイグレーションを追加（既存テーブルに列を足す） | `docker compose run --rm web bin/rails db:migrate` を実行したあと、`docker compose restart web` が必要。しないと起動中のサーバーが古い列情報を持ったままで、`undefined method 'xxx_id'` の 500 エラーになる | デプロイ時に実行して再起動 |
| `Gemfile` に gem を追加 | 必要。`docker compose up -d --build`（または `docker compose restart web`） | 再ビルド |
| `config/initializers/` を編集 | 必要（initializer は起動時にしか読まれない） | 再起動 |

データはコードに書かれていて DB には入らないため、カテゴリを増減しても `db:migrate` や `db:seed` は要りません。

### エンドポイント

`Category` は DB のテーブルではなく専用のコントローラも作っていないので、`/categories` のような URL はありません。カテゴリは記事のエンドポイント経由で扱います。

| メソッド | パス | カテゴリとの関係 |
|----------|------|------------------|
| GET | `/blogs` | 一覧にカテゴリ列を表示 |
| GET | `/blogs/:id` | 詳細にカテゴリのバッジを表示 |
| GET | `/blogs/new`, `/blogs/:id/edit` | フォームのセレクトボックスに `Category.all` を表示 |
| POST | `/blogs` | `blog[category_id]` を受け取って保存 |
| PATCH/PUT | `/blogs/:id` | `blog[category_id]` を更新 |

選択肢を JSON で返す API が必要になったら、`resources :categories, only: %i[index show]` を追加し、`render json: Category.all` で返します。

### ブラウザで確認する

1. `docker compose up -d` でアプリを起動する
2. http://localhost:3000 を開き、ログインして「新規作成」を押す
3. 「カテゴリ」のセレクトに「技術」「日記」が出ることを確認する
4. 保存すると詳細にバッジ、一覧にカテゴリ列が表示される

### ターミナルで見る

**rails console（対話形式）**

```bash
docker compose run --rm web bin/rails console
```

```ruby
Category.all                        # 全件
Category.find(1)                    # id で1件
Category.find_by(name: "日記")       # 条件で1件
Category.pluck(:name)               # => ["技術", "日記"]
Blog.last.category&.name            # 記事のカテゴリ名
Blog.where(category_id: 1).count    # カテゴリごとの件数
Blog.group(:category_id).count      # => { 1 => 3, 2 => 1, nil => 5 }
```

**1行で実行（runner）**

```bash
docker compose run --rm web bin/rails runner 'puts Category.all.map { |c| "#{c.id}: #{c.name}" }'
```

**DB の保存値を見る**

保存されているのは `category_id`（整数）だけで、名前は DB にありません。

```bash
docker compose exec db sh -c 'psql -U "$POSTGRES_USER" -d "${POSTGRES_DB:-blog_development}" -c "select id, title, category_id from blogs;"'
```

ユーザー名とデータベース名は、db コンテナの環境変数（`POSTGRES_USER` / `POSTGRES_DB`）から取っています。

**HTTP で確認する（curl）**

```bash
curl -s http://localhost:3000/blogs | grep -E "技術|日記"
```

`/blogs/new` と作成・更新はログインが必要です。

## 複数マスタの例：Prefecture（都道府県）

`Category`（2件）に続く、47件のマスタです。`users.prefecture_id` に番号だけを保存します。

```ruby
# app/models/prefecture.rb
class Prefecture < ActiveHash::Base
  NAMES = %w[北海道 青森県 ... 沖縄県].freeze
  self.data = NAMES.each_with_index.map { |name, i| { id: i + 1, name: name } }
end
```

- id は JIS コード順（1=北海道、13=東京都、47=沖縄県）。保存済みの値の意味が変わるので、並べ替えや削除はしません。
- `User` に `extend ActiveHash::Associations::ActiveRecordExtensions` と `belongs_to :prefecture, optional: true` を書きます。
- Devise は `prefecture_id` を自動では受け取りません。`ApplicationController` の `configure_permitted_parameters` で `:sign_up` と `:account_update` に許可しています。
- 画面は、登録（`/users/sign_up`）と編集（`/users/edit`）のセレクトで選び、記事詳細の投稿者名の横に表示します。

```ruby
Prefecture.count                       # => 47
Prefecture.find(13).name               # => "東京都"
User.find_by(email: "...").prefecture&.name
User.group(:prefecture_id).count       # 都道府県ごとの人数
```

## よく使う派生

**定数で引く（`ActiveHash::Enum`）**

```ruby
class Category < ActiveHash::Base
  include ActiveHash::Enum

  self.data = [
    { id: 1, name: "tech", label: "技術" },
    { id: 2, name: "diary", label: "日記" }
  ]

  enum_accessor :name
end

Category::TECH.label # => "技術"
```

定数名になる値は一意にします。記号は除かれ、大文字になります（`"tech"` → `TECH`）。

**YAML（`ActiveYaml::Base`）**

`app/models/categories.yml` に配列またはハッシュで書き、クラスは `class Category < ActiveYaml::Base` にします。ハッシュ形式ではキーが `key` 属性になります（`Category.find_by(key: "tech")`）。

## 注意

- v3 以降、`where` などの戻り値は `Array` ではなく `ActiveHash::Relation` です。`each` や `map` はそのまま使えます。
- レコードは読み取り専用（`readonly?` は true）です。実行時に `create` するとメモリ上の一覧に追加されますが、プロセスが終わると消えます。クラスに書いた初期データはファイルに書き戻されません。
- テストでメモリ上に足したレコードは `Category.delete_all` で消せます。初期データも一緒に消えるので、必要なときはテスト後に読み直します。
- 翻訳は Active Record ではなく Active Model 側です。`config/locales` では `activemodel.models.category` にモデル名を書きます。
