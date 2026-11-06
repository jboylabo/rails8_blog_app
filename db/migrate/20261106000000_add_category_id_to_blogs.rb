class AddCategoryIdToBlogs < ActiveRecord::Migration[8.1]
  def change
    # Category は ActiveHash（テーブルなし）なので外部キー制約は付けない。
    # 既存記事はカテゴリ未設定のため null を許可する。
    add_column :blogs, :category_id, :integer
    add_index :blogs, :category_id
  end
end
