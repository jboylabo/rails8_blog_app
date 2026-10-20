demo_password = ENV.fetch("DEMO_USER_PASSWORD") do
  abort "Set DEMO_USER_PASSWORD in .env (see .env.example)"
end

demo = User.find_or_create_by!(email: "demo@example.com") do |user|
  user.password = demo_password
  user.password_confirmation = demo_password
end

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
  blog = Blog.active.find_or_initialize_by(title: attrs[:title])
  blog.assign_attributes(post: attrs[:post], user: demo)
  blog.save!
end

puts "Seeded demo user (#{demo.email}) and #{Blog.active.count} blogs"
