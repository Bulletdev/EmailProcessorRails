require 'rails_helper'

RSpec.describe 'EmailLogs' do
  describe 'GET /email_logs' do
    it 'returns a successful response' do
      get email_logs_path
      expect(response).to be_successful
    end

    it 'displays email logs' do
      email_log = create(:email_log)
      get email_logs_path
      expect(response.body).to include(email_log.filename)
    end

    it 'filters by status' do
      success_log = create(:email_log, status: :success)
      create(:email_log, :failed)

      get email_logs_path(status: 'success')
      expect(response.body).to include(success_log.filename)
    end
  end
end
