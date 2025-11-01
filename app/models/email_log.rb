class EmailLog < ApplicationRecord
  has_one_attached :eml_file

  enum :status, { pending: 0, success: 1, failed: 2 }

  validates :filename, presence: true
  validates :status, presence: true

  scope :recent_first, -> { order(created_at: :desc) }
  scope :successful, -> { where(status: :success) }
  scope :failed_logs, -> { where(status: :failed) }
end
