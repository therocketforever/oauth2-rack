$: << File.expand_path('../lib', __FILE__)
require 'oauth2/rack'

access_token_finder = proc { |options|
  {
    'access_token' => 'test'
  }
}

client_authentication_proc = proc { }

class MockClient
  def initialize(app)
    @app = app
  end

  def call(env)
    env['oauth2.client'] = Object.new
    @app.call(env)
  end
end

map '/client_credentials/access_token' do
  use MockClient
  use OAuth2::Rack::Authorization::ClientCredentials::AccessTokenIssuer, :access_token_finder => access_token_finder
  run proc { [200, {'Content-Type' => 'text/html'}, ['Hello']] }
end
