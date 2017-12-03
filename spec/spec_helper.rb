require 'rspec'
require 'rspec/collection_matchers'
require 'rspec/its'
require 'fileutils'
require 'tmpdir'

Dir["./spec/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.filter_run :focus
  config.expose_dsl_globally = true
  config.run_all_when_everything_filtered = true

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
    c.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.before(:each) do
    ARGV.clear                                 # Make sure no args are passed to the commands.
    @directory = Dir.mktmpdir('new-project-template-spec-') # Create a temp directory to work in.
    @orig_directory = Dir.pwd                  # Save the original directory.
    Dir.chdir(@directory)                      # Change to it. pwd() is the temp directory in the examples.
    puts "Installing Rails template at #{@directory}"
  end

  config.after(:each) do
    Dir.chdir(@orig_directory)                 # Change back to the origin directory.
    FileUtils.rmtree(@directory)               # Remove the temp directory.
  end
end
