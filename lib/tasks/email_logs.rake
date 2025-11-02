namespace :email_logs do
  desc 'Clean up old email logs (default: older than 90 days)'
  task :cleanup, [:days] => :environment do |_t, args|
    days_to_keep = (args[:days] || 90).to_i

    puts "Starting cleanup of email logs older than #{days_to_keep} days..."

    result = CleanupEmailLogsJob.perform_now(days_to_keep)

    puts 'Cleanup completed!'
    puts "Deleted #{result[:deleted_count]} email log(s)"
    puts "Cutoff date: #{result[:cutoff_date].strftime('%Y-%m-%d %H:%M:%S')}"
  end

  desc 'Show email logs statistics'
  task stats: :environment do
    total_count = EmailLog.count
    success_count = EmailLog.successful.count
    failed_count = EmailLog.failed_logs.count
    oldest_log = EmailLog.order(:created_at).first
    newest_log = EmailLog.order(:created_at).last

    puts "\n=== Email Logs Statistics ==="
    puts "Total logs: #{total_count}"
    puts "Successful: #{success_count}"
    puts "Failed: #{failed_count}"

    if oldest_log
      oldest_time = oldest_log.created_at.strftime('%Y-%m-%d %H:%M:%S')
      puts "Oldest log: #{oldest_time} (#{time_ago_in_words(oldest_log.created_at)} ago)"
    end

    if newest_log
      newest_time = newest_log.created_at.strftime('%Y-%m-%d %H:%M:%S')
      puts "Newest log: #{newest_time} (#{time_ago_in_words(newest_log.created_at)} ago)"
    end

    puts "===========================\n"
  end

  private

  def time_ago_in_words(from_time)
    distance_in_seconds = (Time.current - from_time).to_i
    distance_in_days = distance_in_seconds / 86_400

    if distance_in_days > 365
      "#{(distance_in_days / 365.0).round(1)} years"
    elsif distance_in_days > 30
      "#{(distance_in_days / 30.0).round(1)} months"
    elsif distance_in_days.positive?
      "#{distance_in_days} days"
    else
      'today'
    end
  end
end
