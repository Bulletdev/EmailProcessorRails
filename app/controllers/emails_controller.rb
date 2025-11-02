class EmailsController < ApplicationController
  def new; end

  def create
    if params[:eml_files].present?
      files = params[:eml_files]
      uploaded_count = 0

      files.each do |file|
        next if file.blank?

        email_log = EmailLog.create!(
          filename: file.original_filename,
          status: :pending
        )

        email_log.eml_file.attach(file)

        # Enfileira com pequeno delay para garantir que o ActiveStorage terminou
        ProcessEmailJob.set(wait: 2.seconds).perform_later(email_log.id)

        uploaded_count += 1
      end

      if uploaded_count.positive?
        message = if uploaded_count == 1
                    '📧 1 email uploaded successfully!'
                  else
                    "📧 #{uploaded_count} emails uploaded successfully!"
                  end
        message += ' Processing will complete in a few seconds. The page will auto-refresh.'

        redirect_to email_logs_path, notice: message
      else
        redirect_to new_email_path, alert: 'No valid files were uploaded'
      end
    else
      redirect_to new_email_path, alert: 'Please select at least one file to upload'
    end
  end

  def reprocess
    email_log = EmailLog.find(params[:id])

    email_log.update!(
      status: :pending,
      error_message: nil,
      processed_at: nil
    )

    ProcessEmailJob.perform_later(email_log.id)

    redirect_to email_logs_path, notice: 'Email queued for reprocessing!'
  end
end
