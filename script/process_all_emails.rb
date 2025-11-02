Rails.logger.debug 'Processing all test emails...'
Rails.logger.debug ''

Dir.glob('emails/*.eml').each do |file|
  filename = File.basename(file)
  Rails.logger.debug { "Processing #{filename}..." }

  email_log = EmailLog.create!(filename: filename, status: :pending)
  email_log.eml_file.attach(io: File.open(file), filename: filename, content_type: 'message/rfc822')

  ProcessEmailJob.perform_now(email_log.id)
  email_log.reload

  Rails.logger.debug { "  Status: #{email_log.status}" }
  Rails.logger.debug { "  Sender: #{email_log.sender || 'none'}" }
  Rails.logger.debug { "  Error: #{email_log.error_message}" } if email_log.failed?
  Rails.logger.debug ''
end

Rails.logger.debug '=== Summary ==='
Rails.logger.debug { "Total customers created: #{Customer.count}" }
Rails.logger.debug { "Success: #{EmailLog.successful.count}" }
Rails.logger.debug { "Failed: #{EmailLog.failed_logs.count}" }
