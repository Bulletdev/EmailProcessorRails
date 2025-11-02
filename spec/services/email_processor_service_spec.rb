require 'rails_helper'

RSpec.describe EmailProcessorService do
  let(:email_log) { create(:email_log, :with_file) }

  describe '.process' do
    context 'with valid Fornecedor A email' do
      before do
        mail_content = <<~EML
          From: fornecedora@example.com
          Subject: Test Product

          Nome: João Silva
          Email: joao@example.com
          Telefone: (11) 98765-4321
          Produto: XYZ-100
        EML

        email_log.eml_file.attach(
          io: StringIO.new(mail_content),
          filename: 'test.eml',
          content_type: 'message/rfc822'
        )
      end

      it 'creates a customer and updates email log' do
        expect do
          described_class.process(email_log)
        end.to change(Customer, :count).by(1)

        email_log.reload
        expect(email_log.status).to eq('success')
        expect(email_log.sender).to eq('fornecedora@example.com')
        expect(email_log.extracted_data['name']).to eq('João Silva')
      end
    end

    context 'with valid Parceiro B email' do
      before do
        mail_content = <<~EML
          From: parceirob@example.com
          Subject: Product Inquiry

          Customer Name: Ana Costa
          Contact Email: ana@example.com
          Phone: (85) 99123-4567
          Product Code: GHI-750
        EML

        email_log.eml_file.attach(
          io: StringIO.new(mail_content),
          filename: 'test.eml',
          content_type: 'message/rfc822'
        )
      end

      it 'creates a customer and updates email log' do
        expect do
          described_class.process(email_log)
        end.to change(Customer, :count).by(1)

        email_log.reload
        expect(email_log.status).to eq('success')
        expect(email_log.sender).to eq('parceirob@example.com')
      end
    end

    context 'with unknown sender' do
      before do
        mail_content = <<~EML
          From: unknown@example.com
          Subject: Test

          Some content
        EML

        email_log.eml_file.attach(
          io: StringIO.new(mail_content),
          filename: 'test.eml',
          content_type: 'message/rfc822'
        )
      end

      it 'marks email log as failed' do
        described_class.process(email_log)

        email_log.reload
        expect(email_log.status).to eq('failed')
        expect(email_log.error_message).to include('Unknown sender')
      end
    end

    context 'with missing contact information' do
      before do
        mail_content = <<~EML
          From: fornecedora@example.com
          Subject: Test

          Nome: Pedro
          Produto: ABC-123
        EML

        email_log.eml_file.attach(
          io: StringIO.new(mail_content),
          filename: 'test.eml',
          content_type: 'message/rfc822'
        )
      end

      it 'marks email log as failed' do
        described_class.process(email_log)

        email_log.reload
        expect(email_log.status).to eq('failed')
        expect(email_log.error_message).to include('No contact information found')
      end
    end
  end
end
