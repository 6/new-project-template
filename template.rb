RUBY_VERSION = '2.3.4'
# Rubycop only supports major versions (e.g. 2.3) not minor version (2.3.1).
RUBOCOP_TARGET_RUBY_VERSION = RUBY_VERSION.split(".").first(2).join(".")
NODE_VERSION = '7.1.0'

def apply_template
  add_template_repository_to_source_path

  template '.ruby-version.tt'
  template '.rubocop.yml.tt'
  template 'Gemfile.tt', force: true
  template 'Guardfile.tt'
  template 'circle.yml.tt'
  template 'config/secrets.yml.tt', force: true

  remove_file 'app/assets/stylesheets/application.css'
  copy_file 'app/assets/stylesheets/application.scss'
  copy_file 'app/assets/stylesheets/pages/_landing-pages.scss'
  copy_file 'app/controllers/healthchecks_controller.rb'
  copy_file 'app/controllers/landing_pages_controller.rb'
  copy_file 'app/helpers/application_helper.rb', force: true
  copy_file 'app/views/landing_pages/show.html.erb'
  copy_file 'app/views/layouts/application.html.erb', force: true
  copy_file 'app/views/shared/third_party/_rollbar.html.erb'
  copy_file 'config/newrelic.yml'
  copy_file 'config/puma.rb', force: true
  copy_file 'config/sidekiq.yml'
  copy_file 'config/initializers/redis.rb'
  copy_file 'config/initializers/rollbar.rb'
  copy_file 'config/initializers/rack_timeout.rb'
  copy_file '.gitignore', force: true
  copy_file '.rspec'
  copy_file 'Procfile'
  copy_file 'spec/spec_helper.rb'
  copy_file 'spec/models/factory_girl_spec.rb'

  application do
    <<-CONFIG
redis_uri = URI.parse(Rails.application.secrets.redis_url)
redis_config = {host: redis_uri.host, password: redis_uri.password, port: redis_uri.port}

config.cache_store = :redis_store, redis_config.merge(namespace: 'cache')
config.session_store :redis_store, servers: redis_config.merge(namespace: 'session'), expires_in: 1.day

config.active_job.queue_adapter = :sidekiq

if !Rails.env.test? && Rails.application.secrets.aws_s3_bucket.present?
  config.paperclip_defaults = {
    storage: :s3,
    bucket: Rails.application.secrets.aws_s3_bucket,
    s3_credentials: {
      access_key_id: Rails.application.secrets.aws_access_key_id,
      secret_access_key: Rails.application.secrets.aws_secret_access_key,
    },
    s3_region: Rails.application.secrets.aws_region,
    s3_protocol: :https,
    s3_permissions: :private,
    preserve_files: 'true',
  }
end
    CONFIG
  end

  application(nil, env: 'test') do
    <<-CONFIG
config.cache_store = :null_store
    CONFIG
  end

  application(nil, env: 'production') do
    <<-CONFIG
config.force_ssl = true

if Rails.application.secrets.sendgrid_username.present?
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = true
  config.action_mailer.smtp_settings = {
    user_name: Rails.application.secrets.sendgrid_username,
    password: Rails.application.secrets.sendgrid_password,
    domain: Rails.application.secrets.app_domain,
    address: 'smtp.sendgrid.net',
    port: 587,
    authentication: :plain,
    enable_starttls_auto: true,
  }
end
    CONFIG
  end

  route <<-ROUTES
require 'sidekiq/web'
Sidekiq::Web.use Rack::Auth::Basic do |username, password|
  ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(username), ::Digest::SHA256.hexdigest(Rails.application.secrets.sidekiq_username)) &
    ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(password), ::Digest::SHA256.hexdigest(Rails.application.secrets.sidekiq_password))
end
mount Sidekiq::Web, at: '/sidekiq'

resource :healthcheck, only: [:show]
root to: 'landing_pages#show'
  ROUTES

  after_bundle do
    rails_command 'db:drop'
    rails_command 'db:create'
    # Spring occasionally interferes with `rails g`.
    run 'DISABLE_SPRING=1 rails generate paper_trail:install'
    rails_command 'db:migrate'

    git :init
    git add: '.'
    git commit: %Q{ -m 'Initial commit' }
  end
end

# Add this template directory to source_paths so that Thor actions like
# copy_file and template resolve against our source files. If this file was
# invoked remotely via HTTP, that means the files are not present locally.
# In that case, use `git clone` to download them to a local temporary dir.
#
# Taken from: https://github.com/mattbrictson/rails-template
def add_template_repository_to_source_path
  if __FILE__ =~ %r{\Ahttps?://}
    source_paths.unshift(tempdir = Dir.mktmpdir('rails-template-'))
    at_exit { FileUtils.remove_entry(tempdir) }
    git :clone => [
      '--quiet',
      'https://github.com/mattbrictson/rails-template.git',
      tempdir
    ].map(&:shellescape).join(' ')
  else
    source_paths.unshift(File.dirname(__FILE__))
  end
end

apply_template
