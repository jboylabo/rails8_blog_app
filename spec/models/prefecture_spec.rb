require "rails_helper"

RSpec.describe Prefecture do
  it "has 47 prefectures" do
    expect(Prefecture.count).to eq(47)
  end

  it "finds by id" do
    expect(Prefecture.find(13).name).to eq("東京都")
    expect(Prefecture.find(47).name).to eq("沖縄県")
  end

  it "finds by name" do
    expect(Prefecture.find_by(name: "北海道").id).to eq(1)
  end
end
