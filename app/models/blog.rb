class Blog < ApplicationRecord
  belongs_to :user

  validates :title, :post, presence: true

  scope :active, -> { where(deleted_at: nil) }

  def soft_delete!
    update!(deleted_at: Time.current)
  end
end
