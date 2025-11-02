class DashboardController < ApplicationController
  def index
    setup_period_filter
    load_total_counts
    load_recent_activity
    load_chart_data
  end

  private

  def setup_period_filter
    @period = params[:period]&.to_i || 30
    @period = 'all' if params[:period] == 'all'

    @start_date = @period == 'all' ? EmailLog.minimum(:created_at) : @period.days.ago
    @end_date = Time.current

    @filtered_logs = @period == 'all' ? EmailLog.all : EmailLog.where(created_at: @start_date..@end_date)
  end

  def load_total_counts
    @total_emails = EmailLog.count
    @successful_emails = EmailLog.successful.count
    @failed_emails = EmailLog.failed_logs.count
    @pending_emails = EmailLog.where(status: :pending).count
    @total_customers = Customer.count
  end

  def load_recent_activity
    @recent_logs = EmailLog.recent_first.limit(5)
    @recent_customers = Customer.order(created_at: :desc).limit(5)
  end

  def load_chart_data
    @status_counts = {
      success: @filtered_logs.successful.count,
      failed: @filtered_logs.where(status: :failed).count,
      pending: @filtered_logs.where(status: :pending).count
    }

    @emails_by_day = calculate_emails_by_day(@filtered_logs, @start_date, @end_date)
  end

  def calculate_emails_by_day(logs, start_date, end_date)
    return {} if start_date.nil?

    grouped = logs.group_by { |log| log.created_at.to_date }
    dates = (start_date.to_date..end_date.to_date).to_a

    dates.index_with { |date| grouped[date]&.size || 0 }
  end
end
