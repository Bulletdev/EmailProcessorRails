require 'rails_helper'

RSpec.describe 'Emails' do
  describe 'GET /emails/new' do
    it 'returns a successful response' do
      get new_email_path
      expect(response).to be_successful
    end
  end

  describe 'POST /emails' do
    it 'creates an email log and enqueues a job' do
      file = Rack::Test::UploadedFile.new(
        Rails.root.join('emails/email1.eml'),
        'message/rfc822'
      )

      expect do
        post emails_path, params: { eml_files: [file] }
      end.to change(EmailLog, :count).by(1)
                                     .and have_enqueued_job(ProcessEmailJob)

      expect(response).to redirect_to(email_logs_path)
    end

    it 'shows error when no file is provided' do
      expect do
        post emails_path
      end.not_to change(EmailLog, :count)

      expect(response).to redirect_to(new_email_path)
    end
  end
end
