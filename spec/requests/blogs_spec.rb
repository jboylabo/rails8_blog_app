require "rails_helper"

RSpec.describe "Blogs", type: :request do
  let!(:blog) { create(:blog, title: "Fixture Blog Title", post: "Fixture body") }

  describe "GET /blogs" do
    it "TC-R01: returns success and lists factory blog title" do
      get blogs_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Fixture Blog Title")
    end
  end

  describe "GET /blogs/:id" do
    it "TC-R02: returns success and shows blog body" do
      get blog_path(blog)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Fixture body")
    end

    it "TC-R03: returns not found for a soft-deleted blog" do
      blog.soft_delete!

      get blog_path(blog)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /blogs/new" do
    it "TC-R04: redirects unauthenticated users to sign in" do
      get new_blog_path

      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
