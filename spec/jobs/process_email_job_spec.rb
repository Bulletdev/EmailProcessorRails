require 'rails_helper'

RSpec.describe ProcessEmailJob do
  describe '#perform' do
    let(:email_log) { create(:email_log, :pending, :with_file) }

    before do
      mail_content = <<~EML
        From: fornecedora@example.com
        Subject: Test

        Nome: Test User
        Email: test@example.com
        Telefone: (11) 1234-5678
        Produto: TEST-001
      EML

      email_log.eml_file.attach(
        io: StringIO.new(mail_content),
        filename: 'test.eml',
        content_type: 'message/rfc822'
      )
    end

    it 'calls EmailProcessorService.process with the correct email log' do
      expect(EmailProcessorService).to receive(:process).with(email_log)
      described_class.perform_now(email_log.id)
    end

    it 'processes the email successfully' do
      expect do
        described_class.perform_now(email_log.id)
      end.to change(Customer, :count).by(1)
    end
  end
end
