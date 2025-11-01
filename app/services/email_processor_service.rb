class EmailProcessorService
  PARSERS = {
    'loja@fornecedorA.com' => FornecedorAParser,
    'contato@parceiroB.com' => ParceiroBParser,
    # Legacy support
    'fornecedora@example.com' => FornecedorAParser,
    'parceirob@example.com' => ParceiroBParser
  }.freeze

  def self.process(email_log)
    new(email_log).process
  end

  def initialize(email_log)
    @email_log = email_log
  end

  def process
    mail_content = @email_log.eml_file.download
    mail = Mail.read_from_string(mail_content)

    sender = extract_sender(mail)
    parser = select_parser(sender)

    raise StandardError, "Unknown sender: #{sender}" unless parser

    extracted_data = parser.new.parse(mail_content)

    # Usa find_or_create_by para evitar duplicatas (idempotência)
    # Se tem email, usa email como chave única
    # Se não tem email, usa telefone como chave única
    if extracted_data[:email].present?
      customer = Customer.find_or_create_by!(email: extracted_data[:email]) do |c|
        c.assign_attributes(extracted_data)
      end
    elsif extracted_data[:phone].present?
      customer = Customer.find_or_create_by!(phone: extracted_data[:phone]) do |c|
        c.assign_attributes(extracted_data)
      end
    else
      # Não deveria chegar aqui por causa da validação, mas por segurança...
      raise StandardError, 'No contact information (email or phone) found'
    end

    @email_log.update!(
      sender: sender,
      status: :success,
      extracted_data: extracted_data,
      processed_at: Time.current
    )

    { success: true, customer: customer }
  rescue StandardError => e
    @email_log.update!(
      status: :failed,
      error_message: e.message,
      processed_at: Time.current
    )

    { success: false, error: e.message }
  end

  private

  def extract_sender(mail)
    mail.from.first if mail.from.present?
  end

  def select_parser(sender)
    PARSERS[sender]
  end
end
