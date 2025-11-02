require 'rails_helper'

RSpec.describe FornecedorAParser do
  let(:parser) { described_class.new }

  describe '#parse' do
    context 'with complete data' do
      let(:mail_content) do
        <<~EML
          From: fornecedora@example.com
          To: sales@company.com
          Subject: Test Product

          Nome: João Silva
          Email: joao@example.com
          Telefone: (11) 98765-4321
          Produto: XYZ-100
        EML
      end

      it 'extracts all customer information' do
        result = parser.parse(mail_content)

        expect(result[:name]).to eq('João Silva')
        expect(result[:email]).to eq('joao@example.com')
        expect(result[:phone]).to eq('(11) 98765-4321')
        expect(result[:product_code]).to eq('XYZ-100')
        expect(result[:subject]).to eq('Test Product')
      end
    end

    context 'with alternative field names' do
      let(:mail_content) do
        <<~EML
          From: fornecedora@example.com
          Subject: Inquiry

          Cliente: Maria Santos
          E-mail: maria@example.com
          Tel: (21) 3344-5566
          Código: ABC-250
        EML
      end

      it 'extracts data using alternative patterns' do
        result = parser.parse(mail_content)

        expect(result[:name]).to eq('Maria Santos')
        expect(result[:email]).to eq('maria@example.com')
        expect(result[:phone]).to eq('(21) 3344-5566')
        expect(result[:product_code]).to eq('ABC-250')
      end
    end

    context 'with missing contact information' do
      let(:mail_content) do
        <<~EML
          From: fornecedora@example.com
          Subject: Test

          Nome: Pedro Oliveira
          Produto: DEF-500
        EML
      end

      it 'raises an error' do
        expect { parser.parse(mail_content) }.to raise_error(StandardError, /No contact information found/)
      end
    end

    context 'with natural language product code patterns' do
      it 'extracts from "produto de código ABC123"' do
        mail_content = <<~EML
          From: fornecedora@example.com
          Subject: Test

          Gostaria de solicitar informações sobre o produto de código ABC123.
          Nome: João Silva
          Email: joao@test.com
        EML

        result = parser.parse(mail_content)
        expect(result[:product_code]).to eq('ABC123')
      end

      it 'extracts from "produto XYZ987"' do
        mail_content = <<~EML
          From: fornecedora@example.com
          Subject: Test

          Tenho interesse no produto XYZ987.
          Nome: Maria Costa
          Telefone: 11 99999-9999
        EML

        result = parser.parse(mail_content)
        expect(result[:product_code]).to eq('XYZ987')
      end

      it 'extracts from subject line "Produto ABC123"' do
        mail_content = <<~EML
          From: fornecedora@example.com
          Subject: Pedido de orçamento - Produto ABC123

          Nome: Test User
          Email: test@test.com
        EML

        result = parser.parse(mail_content)
        expect(result[:product_code]).to eq('ABC123')
      end

      it 'extracts standalone product codes using fallback pattern' do
        mail_content = <<~EML
          From: fornecedora@example.com
          Subject: Test

          Preciso de informações sobre LMN456.
          Nome: Test User
          Email: test@test.com
        EML

        result = parser.parse(mail_content)
        expect(result[:product_code]).to eq('LMN456')
      end
    end
  end
end
