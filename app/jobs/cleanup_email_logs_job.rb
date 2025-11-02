class CleanupEmailLogsJob < ApplicationJob
  queue_as :default

  # Delete email logs older than 90 days
  # This helps maintain database performance and comply with data retention policies
  def perform(days_to_keep = 90)
    cutoff_date = days_to_keep.days.ago

    # Find logs to delete
    logs_to_delete = EmailLog.where(created_at: ...cutoff_date)
    deleted_count = logs_to_delete.count

    # Delete the logs (Active Storage attachments will be automatically purged)
    logs_to_delete.destroy_all

    Rails.logger.info "CleanupEmailLogsJob: Deleted #{deleted_count} email logs older than #{days_to_keep} days"

    { deleted_count: deleted_count, cutoff_date: cutoff_date }
  end
end
