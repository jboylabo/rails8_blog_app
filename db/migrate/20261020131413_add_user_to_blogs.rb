class AddUserToBlogs < ActiveRecord::Migration[8.1]
  DEMO_EMAIL = "demo@example.com"

  def up
    add_reference :blogs, :user, foreign_key: true, null: true

    say_with_time "Assigning existing blogs to demo user" do
      password = ENV.fetch("DEMO_USER_PASSWORD") do
        raise ActiveRecord::MigrationError, "Set DEMO_USER_PASSWORD in .env before migrating"
      end
      user = User.find_or_create_by!(email: DEMO_EMAIL) do |record|
        record.password = password
        record.password_confirmation = password
      end
      Blog.unscoped.where(user_id: nil).update_all(user_id: user.id)
    end

    change_column_null :blogs, :user_id, false
  end

  def down
    remove_reference :blogs, :user, foreign_key: true
  end
end
