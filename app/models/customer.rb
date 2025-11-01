class Customer < ApplicationRecord
  validates :name, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :phone, presence: true, if: -> { email.blank? }
  validates :email, presence: true, if: -> { phone.blank? }

  validate :must_have_contact_info

  private

  def must_have_contact_info
    return unless email.blank? && phone.blank?

    errors.add(:base, 'Must have at least email or phone')
  end
end
