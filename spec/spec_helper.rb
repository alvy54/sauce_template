require "capybara"
require "capybara/rspec"
require "sauce"
require "sauce/capybara"
require "selenium-webdriver"
require "capybara-screenshot/rspec"

if ENV["RUN_ON_SAUCE"]
  Capybara.default_driver = :sauce
else
  Capybara.default_driver = :selenium
  Capybara.run_server = false
end

Sauce.config do |config|
  config[:start_local_application] = false
  config[:start_tunnel] = ENV["RUN_ON_SAUCE"]
  config[:sauce_connect_4_executable] = ENV["SAUCE_CONNECT_4_EXECUTABLE"]
  options = { :screenResolution => "1280x1024" }
  config[:browsers] = [
    ["OS X 10.10", "Safari", "8.0", options],
    ["Windows 7", "Firefox", "40", options],
    ["Windows 8.1", "Internet Explorer", "11", options],
    ["Windows 8", "Chrome", nil, options]
  ]
end

Capybara.register_driver :selenium do |app|
  if ENV["HEADLESS"]
    require "headless"
    headless = Headless.new
    headless.start
  end

  ENV["BROWSER"] ||= "firefox"
  case ENV["BROWSER"]
  when "firefox"
    capabilities = Selenium::WebDriver::Remote::Capabilities.firefox
  when "safari"
    capabilities = Selenium::WebDriver::Remote::Capabilities.safari
  when "ie"
    capabilities = Selenium::WebDriver::Remote::Capabilities.ie
  else
    capabilities = Selenium::WebDriver::Remote::Capabilities.chrome
  end

  options = { :browser => ENV["BROWSER"].to_sym }
  unless ENV["REMOTE_URL"].nil?
    options = { :browser => :remote, :url => ENV["REMOTE_URL"], :desired_capabilities => capabilities }
  end

  Capybara::Selenium::Driver.new(app, options)
end

Capybara.save_and_open_page_path = "tmp/capybara"
Capybara::Screenshot.append_timestamp = false
Capybara::Screenshot.register_filename_prefix_formatter(:rspec) do |example|
  "screenshot_#{example.description.gsub(' ', '-').gsub(/^.*\/spec\//,'')}"
end
Capybara::Screenshot.prune_strategy = { keep: 20 }
Capybara::Screenshot::RSpec.add_link_to_screenshot_for_failed_examples = false
