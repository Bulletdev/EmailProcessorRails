class EmailLogsController < ApplicationController
  def index
    @email_logs = EmailLog.recent_first

    @email_logs = @email_logs.where(status: params[:status]) if params[:status].present?

    @email_logs = @email_logs.page(params[:page]).per(20)
  end
end
