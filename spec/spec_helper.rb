ENV['RACK_ENV'] = 'test'

# require 'bundler/setup'

require File.expand_path('../main/skn_base', __dir__)

require 'rspec'
require 'capybara/rspec'
require 'capybara/dsl'
require 'rack/test'

require 'warden/test/helpers'
require 'warden/test/warden_helpers'
require "rack_session_access/capybara"
require 'capybara-screenshot/rspec'
require 'capybara/poltergeist'

require 'simplecov'
require 'code_coverage'

Dir[ Skn::SknBase.opts[:root].join("spec/support/**/*.rb") ].each { |f| require f }

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

  config.include Rack::Test::Methods
  config.include Warden::Test::WardenHelpers          # asset_paths, on_next_request, test_reset!
  config.include Warden::Test::Helpers                # login_as(u, opts), logout(scope), CALLS ::Warden.test_mode!
  config.include FeatureHelpers  #, type: :feature       # logged_as(user) session injection for cucumber/capybara
  config.include TestUsers

  config.before(:each) do
    Capybara.use_default_driver       # switch back to default driver
    # Capybara.default_host = 'http://test.host'
  end

  config.append_after(:each) do
    Warden.test_reset!
    # Capybara.current_session.driver.reset!
    Capybara.reset_sessions!
  end

  def sign_in(user, opts=nil)
    warden.set_user(user,opts)
  end

  def app
    Skn::SknBase.app
  end

end
