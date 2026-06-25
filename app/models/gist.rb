class Gist < ApplicationRecord
  belongs_to :article, optional: true

  validates :title,       presence: true, length: { minimum: 3, maximum: 100 }
  validates :description, length: { maximum: 500 }, allow_blank: true
  validates :code,        presence: true, length: { minimum: 10 }
  validates :language,    presence: true, inclusion: { in: %w[ruby] }

  scope :published,   -> { where(published: true) }
  scope :unpublished, -> { where(published: false) }
  scope :recent,      -> { order(created_at: :desc) }

  def published_status
    published? ? "Published" : "Draft"
  end

  def ran?
    output_at.present?
  end
end
