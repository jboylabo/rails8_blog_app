class CreateBlogs < ActiveRecord::Migration[8.1]
  def change
    create_table :blogs do |t|
      t.string :title, null: false
      t.text :post, null: false
      t.datetime :deleted_at
      t.timestamps
    end
    add_index :blogs, :deleted_at
  end
end