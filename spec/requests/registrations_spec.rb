require "rails_helper"

RSpec.describe "Registrations", type: :request do
  it "shows the prefecture select on the sign up form" do
    get new_user_registration_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("user[prefecture_id]")
    expect(response.body).to include("東京都")
  end

  it "saves prefecture_id on sign up" do
    post user_registration_path, params: {
      user: { email: "new@example.com", password: "test-password-12",
              password_confirmation: "test-password-12", prefecture_id: 27 }
    }

    expect(User.find_by(email: "new@example.com").prefecture.name).to eq("大阪府")
  end
end
