RUBY_VERSION = '2.3.4'
# Rubycop only supports major versions (e.g. 2.3) not minor version (2.3.1).
RUBOCOP_TARGET_RUBY_VERSION = RUBY_VERSION.split(".").first(2).join(".")

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
  copy_file 'config/initializers/redis.rb'
  copy_file 'config/initializers/rollbar.rb'
  copy_file 'config/initializers/rack_timeout.rb'
  copy_file '.gitignore', force: true
  copy_file '.rspec'
  copy_file 'Procfile'
  copy_file 'spec/spec_helper.rb'
  copy_file 'spec/models/factory_girl_spec.rb'

  environment 'config.force_ssl = true', env: 'production'

  route "resource :healthcheck, only: [:show]"
  route "root to: 'landing_pages#show'"

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
