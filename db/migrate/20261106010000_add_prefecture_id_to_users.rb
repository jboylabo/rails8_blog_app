class AddPrefectureIdToUsers < ActiveRecord::Migration[8.1]
  def change
    # Prefecture は ActiveHash（テーブルなし）なので外部キー制約は付けない。
    # 既存ユーザーは未設定のため null を許可する。
    add_column :users, :prefecture_id, :integer
    add_index :users, :prefecture_id
  end
end
