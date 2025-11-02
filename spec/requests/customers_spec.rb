require 'rails_helper'

RSpec.describe 'Customers' do
  describe 'GET /customers' do
    it 'returns a successful response' do
      get customers_path
      expect(response).to be_successful
    end

    it 'displays customers' do
      customer = create(:customer)
      get customers_path
      expect(response.body).to include(customer.name)
    end
  end
end
