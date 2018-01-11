
Capybara.configure do |config|
  config.app = Skn::SknBase.app
  config.server = :puma
  config.default_driver = :mechanize
  config.javascript_driver = :poltergeist
end

def app
  Skn::SknBase.app # Rack::Builder.parse_file("config.ru").first # Skn::SknBase.app
end

Capybara.register_driver :rack_test do |app|
  Capybara::RackTest::Driver.new(app)
  # Capybara::RackTest::Driver.new(app, :browser => :safari)
end

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, {timeout: 300})
  #Capybara::Poltergeist::Driver.new(app, {timeout: 300, debug: true})
end

# Ref: https://github.com/mattheworiordan/capybara-screenshot
# screenshot_and_save_page
# screenshot_and_open_image
#
# Rack::Test Driver does not support screenshots; :poltergeist does support it
#
Capybara::Screenshot.autosave_on_failure = true
Capybara::Screenshot.prune_strategy = :keep_last_run
Capybara.save_path = "tmp/capybara"
Capybara::Screenshot.append_timestamp = true
Capybara::Screenshot::RSpec.add_link_to_screenshot_for_failed_examples = true
Capybara::Screenshot::RSpec::REPORTERS["RSpec::Core::Formatters::HtmlFormatter"] = Capybara::Screenshot::RSpec::HtmlEmbedReporter

def click_logout_link
  Capybara.current_session.driver.delete '/sessions/logout'
end
