require "rails_helper"

RSpec.describe Blog, type: :model do
  describe "factory" do
    it "TC-01: persists a valid blog to the database" do
      expect { create(:blog) }.to change(Blog, :count).by(1)

      blog = create(:blog)
      expect(blog).to be_persisted
      expect(blog.user).to be_present
    end

    it "TC-06: retrieves stub data created by factories" do
      first = create(:blog, title: "Alpha post", post: "First body")
      second = create(:blog, title: "Beta post", post: "Second body")

      expect(Blog.active.pluck(:title)).to contain_exactly(first.title, second.title)
      expect(Blog.find(second.id).post).to eq("Second body")
    end
  end

  describe "validations" do
    it "TC-02: is invalid without a title" do
      blog = build(:blog, title: nil)
      expect(blog).not_to be_valid
      expect(blog.errors[:title]).to be_present
    end

    it "TC-03: is invalid without a post" do
      blog = build(:blog, post: nil)
      expect(blog).not_to be_valid
      expect(blog.errors[:post]).to be_present
    end

    it "TC-04: is invalid without a user" do
      blog = build(:blog, user: nil)
      expect(blog).not_to be_valid
      expect(blog.errors[:user]).to be_present
    end
  end

  describe "#soft_delete! and .active" do
    it "TC-05: excludes soft-deleted blogs from the active scope" do
      blog = create(:blog)
      blog.soft_delete!

      expect(blog.reload.deleted_at).to be_present
      expect(Blog.active).not_to include(blog)
      expect(Blog.unscoped.find(blog.id)).to eq(blog)
    end
  end
end
