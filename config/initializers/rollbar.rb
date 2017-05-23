require 'rollbar/rails'

Rollbar.configure do |config|
  config.access_token = Rails.application.secrets.rollbar_access_token
  config.enabled = Rails.application.secrets.rollbar_enabled == 'true'
  config.environment = Rails.application.secrets.app_env
end
