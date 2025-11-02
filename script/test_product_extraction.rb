# Limpa os dados antigos para testar do zero
Rails.logger.debug 'Cleaning old data...'
Customer.destroy_all
EmailLog.destroy_all
Rails.logger.debug ''

Rails.logger.debug '=' * 60
Rails.logger.debug 'Testing Improved Product Code Extraction'
Rails.logger.debug '=' * 60
Rails.logger.debug ''

test_emails = ['email1.eml', 'email2.eml', 'email3.eml', 'email6.eml']

test_emails.each do |filename|
  filepath = "emails/#{filename}"
  next unless File.exist?(filepath)

  Rails.logger.debug { "Processing: #{filename}" }
  Rails.logger.debug '-' * 60

  email_log = EmailLog.create!(filename: filename, status: :pending)
  email_log.eml_file.attach(io: File.open(filepath), filename: filename, content_type: 'message/rfc822')

  ProcessEmailJob.perform_now(email_log.id)
  email_log.reload

  Rails.logger.debug { "Status: #{email_log.status.upcase}" }
  Rails.logger.debug { "Sender: #{email_log.sender}" } if email_log.sender

  if email_log.success?
    data = email_log.extracted_data
    Rails.logger.debug ''
    Rails.logger.debug 'Extracted Data:'
    Rails.logger.debug { "  Name:         #{data['name']}" }
    Rails.logger.debug { "  Email:        #{data['email']}" }
    Rails.logger.debug { "  Phone:        #{data['phone']}" }
    Rails.logger.debug { "  Product Code: #{data['product_code'] || '(not found)'}" }
    Rails.logger.debug { "  Subject:      #{data['subject']}" }

    Rails.logger.debug ''
    if data['product_code'].present?
      Rails.logger.debug '✅ Product code extracted successfully!'
    else
      Rails.logger.debug '❌ Product code NOT extracted'
    end
  else
    Rails.logger.debug { "Error: #{email_log.error_message}" }
  end

  Rails.logger.debug ''
  Rails.logger.debug ''
end

Rails.logger.debug '=' * 60
Rails.logger.debug 'Summary'
Rails.logger.debug '=' * 60
Rails.logger.debug { "Total Customers: #{Customer.count}" }
Rails.logger.debug { "Customers with Product Code: #{Customer.where.not(product_code: [nil, '']).count}" }
Rails.logger.debug ''

if Customer.any?
  Rails.logger.debug 'Customer Details:'
  Customer.find_each do |c|
    code_display = c.product_code.presence || '(none)'
    Rails.logger.debug { "  - #{c.name} | Product: #{code_display}" }
  end
end
