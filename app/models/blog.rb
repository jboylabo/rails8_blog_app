class Blog < ApplicationRecord
  extend ActiveHash::Associations::ActiveRecordExtensions

  belongs_to :user
  belongs_to :category, optional: true

  validates :title, :post, presence: true

  scope :active, -> { where(deleted_at: nil) }

  def soft_delete!
    update!(deleted_at: Time.current)
  end
end
