ENV['RACK_ENV'] = 'test'

require File.join(File.dirname(__FILE__), '..', 'main/skn_base')

require 'rspec'

require 'capybara'
require 'capybara/rspec'
# require 'rack/test'
# require 'rspec-roda'

# require 'warden/test/helpers'
# require 'warden/test/warden_helpers'
require 'capybara-screenshot/rspec'
require 'capybara/poltergeist'

require 'pry'

require 'simplecov'
require 'code_coverage'

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  Kernel.srand config.seed

  config.order = :random
  config.color = true
  config.tty = false
  config.profile_examples = 10

  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  # config.disable_monkey_patching!  # -- breaks rspec runtime
  config.warnings = true

  if config.files_to_run.one?
    config.formatter = :documentation
  else
    config.formatter = :progress  #:html, :textmate, :documentation
  end

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end

Dir[ "./spec/support/**/*.rb" ].each { |f| puts f ; require f }

RSpec.configure do |config|
  config.include Rack::Test::Methods
  # config.include Warden::Test::WardenHelpers          # asset_paths, on_next_request, test_reset!
  # config.include Warden::Test::Helpers                # login_as(u, opts), logout(scope), CALLS ::Warden.test_mode!
  # config.include FeatureHelpers  #, type: :feature       # logged_as(user) session injection for cucumber/capybara
  config.include TestUsers
end
