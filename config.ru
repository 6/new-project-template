# This file is used by Rack-based servers to start the application.

require_relative 'config/environment'

if ENV['CANONICAL_HOST']
  ignored_domains = (ENV['CANONICAL_HOST_IGNORED'] || "").split(",")
  use Rack::CanonicalHost, ENV['CANONICAL_HOST'], ignore: ignored_domains
end

run Rails.application
