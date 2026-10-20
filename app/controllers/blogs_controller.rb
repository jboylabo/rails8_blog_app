class BlogsController < ApplicationController
  before_action :set_blog, only: %i[show edit update destroy]

  def index
    @blogs = Blog.active.order(created_at: :desc)
  end

  def show
  end

  def new
    @blog = Blog.new
  end

  def create
    @blog = Blog.new(blog_params)
    if @blog.save
      redirect_to @blog, notice: "Blog を作成しました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @blog.update(blog_params)
      redirect_to @blog, notice: "Blog を更新しました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @blog.soft_delete!
    redirect_to blogs_path, notice: "Blog を削除しました。"
  end

  private

  def set_blog
    @blog = Blog.active.find(params[:id])
  end

  def blog_params
    params.require(:blog).permit(:title, :post)
  end
end
