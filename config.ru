$: << File.expand_path('../lib', __FILE__)
require 'oauth2/rack'

class AccessTokenIssuer
  def self.call(opts = {})
    opts.merge('access_token' => 'test')
  end
end
class Authenticator
  def self.call(opts = {})
    if opts[:username]
      authenticate_resource_owner(opts)
    elsif opts[:client_id]
      authenticate_client(opts)
    end
  end

  def self.authenticate_resource_owner(opts)
    OpenStruct.new(:username => opts[:username])
  end

  def self.authenticate_client(opts)
    OpenStruct.new(:client_id => opts[:client_id])
  end
end

map '/password/access_token' do
  use OAuth2::Rack::Authentication::Client::HTTPBasic, :required => false, :authenticator => Authenticator
  use OAuth2::Rack::Authentication::Client::RequestParams, :required => false, :authenticator => Authenticator

  use OAuth2::Rack::Authentication::ResourceOwner::RequestParams, :authenticator => Authenticator

  use OAuth2::Rack::Authorization::Password::AccessTokenIssuer, :issuer => AccessTokenIssuer

  run proc { |env| [200, {'Content-Type' => 'text/html'}, ['Hello']] }
end

map '/client_credentials/access_token' do
  use OAuth2::Rack::Authentication::Client::HTTPBasic, :required => false, :authenticator => Authenticator
  use OAuth2::Rack::Authentication::Client::RequestParams, :required => false, :authenticator => Authenticator

  use OAuth2::Rack::Authorization::ClientCredentials::AccessTokenIssuer, :issuer => AccessTokenIssuer

  run proc { |env| [200, {'Content-Type' => 'text/html'}, ['Hello']] }
end


map '/inspect' do
  run proc { |env| [200, {'Content-Type' => 'text/html'}, [env.inspect]] }
end
