$: << File.expand_path('../../lib', __FILE__)
require 'oauth2/rack'
require 'multi_json'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.expand_path("../support/**/*.rb", __FILE__)].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :rspec
end
