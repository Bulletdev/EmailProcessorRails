class ProcessEmailJob < ApplicationJob
  queue_as :default

  sidekiq_options retry: 3

  def perform(email_log_id)
    email_log = EmailLog.find(email_log_id)

    # Não reprocessa se já foi processado com sucesso
    if email_log.success?
      Rails.logger.info "[ProcessEmailJob] Skipping email_log #{email_log_id} - already processed successfully"
      return
    end

    EmailProcessorService.process(email_log)
  end
end
