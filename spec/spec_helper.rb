ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'database_cleaner'
require 'webmock/rspec'
require 'rspec/its'
require 'rspec/collection_matchers'

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true

  if ENV['CI']
    config.before(:example, :focus) { raise "Should not commit focused specs" }
  else
    config.filter_run focus: true
  end

  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.render_views
  config.fixture_path = Rails.root.join("spec/fixtures")

  puts "Seed: #{RSpec.configuration.seed}"

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
    begin
      DatabaseCleaner.start
    ensure
      DatabaseCleaner.clean
    end
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
    DatabaseCleaner.strategy = :transaction
  end

  # Print the 20 slowest examples and example groups at the
  # end of the spec run, to help surface which specs are running
  # particularly slow.
  # config.profile_examples = 20
end

def response_json
  json = JSON.parse(response.body)
  if json.is_a?(Array)
    json.map(&:with_indifferent_access)
  else
    json.with_indifferent_access
  end
end
