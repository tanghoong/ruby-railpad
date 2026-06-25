class Article < ApplicationRecord
  has_many :gists, dependent: :nullify

  validates :title, presence: true, length: { minimum: 3, maximum: 200 }
  validates :content, presence: true, length: { minimum: 10 }
  validates :author, presence: true, length: { minimum: 2, maximum: 100 }

  scope :published, -> { where(published: true) }
  scope :unpublished, -> { where(published: false) }
  scope :recent, -> { order(created_at: :desc) }

  def published_status
    published ? "Published" : "Draft"
  end
end
