require "rails_helper"

RSpec.describe User, type: :model do
  it "resolves prefecture from prefecture_id" do
    user = create(:user, prefecture_id: 13)
    expect(user.reload.prefecture.name).to eq("東京都")
  end

  it "is valid without a prefecture" do
    expect(build(:user, prefecture_id: nil)).to be_valid
  end
end
