blogs = [
  {
    title: "Docker compose 学習メモ",
    post: "exec は起動中コンテナにプロセスを足す。run は一時コンテナで 1 回だけコマンドを実行する。"
  },
  {
    title: "Rails 8 Hello World",
    post: "コンテナでは PID 1 がサーバプロセス。Puma をフォアグラウンドで動かし、0.0.0.0 で待ち受ける。"
  },
  {
    title: "Blog CRUD 完成",
    post: "論理削除は deleted_at をセットする。一覧は Blog.active で削除済みを除く。seeds で 3 件投入。"
  }
]

blogs.each do |attrs|
  Blog.active.find_or_create_by!(title: attrs[:title]) do |blog|
    blog.post = attrs[:post]
  end
end

puts "Seeded #{Blog.active.count} blogs"
