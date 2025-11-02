class CustomersController < ApplicationController
  def index
    @customers = Customer.order(created_at: :desc).page(params[:page]).per(20)
  end
end
