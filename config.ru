$: << File.expand_path('../lib', __FILE__)
require 'oauth2/rack'

map '/inspect' do
  run proc { |env| [200, {'Content-Type' => 'text/html'}, [env.inspect]] }
end

map '/client_credentials/access_token' do
  use OAuth2::Rack::Authentication::Client::HTTPBasic do |opts|
    OpenStruct.new(:username => opts[:username])
  end
  use OAuth2::Rack::Authorization::ClientCredentials::AccessTokenIssuer do |opts|
    {
      'access_token' => 'test'
    }
  end
  run proc { [200, {'Content-Type' => 'text/html'}, ['Hello']] }
end

