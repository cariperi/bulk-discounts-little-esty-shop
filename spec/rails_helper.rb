# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'simplecov'

SimpleCov.start do
  enable_coverage :branch
  add_filter "spec/rails_helper.rb"
end

require './app/helpers/application_helper'
include ApplicationHelper

require './spec/fixtures/mock_responses'
include MockResponses

require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
require 'webmock/rspec'
# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

RSpec.configure do |config|
  config.before(:each) do
    # WebMock.disable_net_connect!(allow: 'https://date.nager.at')

    api_key = Rails.application.config.unsplash_api_key

    stub_request(:get, "https://api.unsplash.com/photos/qMehmIyaXvY/?client_id=#{api_key}").with(
      headers: {
        'Accept'=>'*/*',
        'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'User-Agent'=>'Ruby'
      })
    .to_return(status: 200, body: LOGO_PHOTO_RESPONSE.to_json)

    stub_request(:get, "https://api.unsplash.com/photos/random/?client_id=#{api_key}")
    .to_return(status: 200, body: RANDOM_PHOTO_RESPONSE.to_json)

    search_term = "Dog"
    stub_request(:get, "https://api.unsplash.com/search/photos?client_id=#{api_key}&page=1&query=#{search_term}")
    .to_return(status: 200, body: SEARCH_PHOTO_RESPONSE.to_json)

    search_term = "Assumenda%20Animi"
    stub_request(:get, "https://api.unsplash.com/search/photos?page=1&query=#{search_term}&client_id=#{api_key}")
    .to_return(status: 200, body: SEARCH_NOT_FOUND_RESPONSE.to_json)

    stub_request(:get, "https://api.unsplash.com/photos/Hl_o1K6OPsA/?client_id=#{api_key}")
    .to_return(status: 200, body: ERROR_PHOTO_RESPONSE.to_json)

    country_code = 'US'
    stub_request(:get, "https://date.nager.at/api/v3/NextPublicHolidays/#{country_code}")
    .to_return(status: 200, body: HOLIDAY_RESPONSE.to_json)
  end

  config.include FactoryBot::Syntax::Methods

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # You can uncomment this line to turn off ActiveRecord support entirely.
  # config.use_active_record = false

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, type: :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
     with.test_framework :rspec
     with.library :rails
  end
end
