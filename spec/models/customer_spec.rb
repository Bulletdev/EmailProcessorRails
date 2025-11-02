require 'rails_helper'

RSpec.describe Customer do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }

    it 'validates email format when present' do
      customer = build(:customer, email: 'invalid-email')
      expect(customer).not_to be_valid
      expect(customer.errors[:email]).to include('is invalid')
    end

    it 'allows nil email' do
      customer = build(:customer_with_phone_only)
      expect(customer).to be_valid
    end

    it 'requires at least one contact method' do
      customer = build(:customer, email: nil, phone: nil)
      expect(customer).not_to be_valid
      expect(customer.errors[:base]).to include('Must have at least email or phone')
    end
  end

  describe 'contact information validation' do
    it 'is valid with only email' do
      customer = build(:customer_with_email_only)
      expect(customer).to be_valid
    end

    it 'is valid with only phone' do
      customer = build(:customer_with_phone_only)
      expect(customer).to be_valid
    end

    it 'is valid with both email and phone' do
      customer = build(:customer)
      expect(customer).to be_valid
    end
  end
end
