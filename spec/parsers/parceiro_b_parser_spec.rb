require 'rails_helper'

RSpec.describe ParceiroBParser do
  let(:parser) { described_class.new }

  describe '#parse' do
    context 'with complete data in English' do
      let(:mail_content) do
        <<~EML
          From: parceirob@example.com
          To: info@company.com
          Subject: Product Inquiry

          Customer Name: Ana Costa
          Contact Email: ana@example.com
          Phone: (85) 99123-4567
          Product Code: GHI-750
        EML
      end

      it 'extracts all customer information' do
        result = parser.parse(mail_content)

        expect(result[:name]).to eq('Ana Costa')
        expect(result[:email]).to eq('ana@example.com')
        expect(result[:phone]).to eq('(85) 99123-4567')
        expect(result[:product_code]).to eq('GHI-750')
        expect(result[:subject]).to eq('Product Inquiry')
      end
    end

    context 'with Portuguese field names' do
      let(:mail_content) do
        <<~EML
          From: parceirob@example.com
          Subject: Cotação

          Nome do Cliente: Carlos Ferreira
          Email de Contato: carlos@example.com
          Telefone: (48) 2211-3344
          Código do Produto: JKL-999
        EML
      end

      it 'extracts data using Portuguese patterns' do
        result = parser.parse(mail_content)

        expect(result[:name]).to eq('Carlos Ferreira')
        expect(result[:email]).to eq('carlos@example.com')
        expect(result[:phone]).to eq('(48) 2211-3344')
        expect(result[:product_code]).to eq('JKL-999')
      end
    end

    context 'with missing contact information' do
      let(:mail_content) do
        <<~EML
          From: parceirob@example.com
          Subject: Test

          Customer Name: Roberto Lima
          Product Code: MNO-123
        EML
      end

      it 'raises an error' do
        expect { parser.parse(mail_content) }.to raise_error(StandardError, /No contact information found/)
      end
    end
  end
end
