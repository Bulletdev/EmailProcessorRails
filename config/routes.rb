Rails.application.routes.draw do
  root "dashboard#index"

  get 'dashboard', to: 'dashboard#index', as: 'dashboard'

  resources :customers, only: [:index]
  resources :email_logs, only: [:index]
  
  resources :emails, only: [:new, :create] do
    member do
      post :reprocess
    end
  end

  require "sidekiq/web"
  
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    ActiveSupport::SecurityUtils.secure_compare(
      ::Digest::SHA256.hexdigest(username),
      ::Digest::SHA256.hexdigest(ENV.fetch("SIDEKIQ_USERNAME", "admin"))
    ) &
    ActiveSupport::SecurityUtils.secure_compare(
      ::Digest::SHA256.hexdigest(password),
      ::Digest::SHA256.hexdigest(ENV.fetch("SIDEKIQ_PASSWORD", "change_me_in_production"))
    )
  end if Rails.env.production? || ENV["SIDEKIQ_AUTH_ENABLED"] == "true"
  
  mount Sidekiq::Web => "/sidekiq"

  get "up" => "rails/health#show", as: :rails_health_check
end
