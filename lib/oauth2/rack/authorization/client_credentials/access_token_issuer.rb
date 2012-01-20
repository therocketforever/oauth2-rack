# @see 4.4.1 Client Credentials
require 'oauth2/rack'
require 'multi_json'

class OAuth2::Rack::Authorization::ClientCredentials::AccessTokenIssuer
  def initialize(app, opts = {}, &issuer)
    @app = app

    @issuer = issuer || opts[:issuer]
  end

  def call(env)
    client = env['oauth2.client']
    unless client
      return error_response(:error => 'invalid_client')
    end

    request = Rack::Request.new(env)
    unless request['grant_type'] == 'client_credentials'
      return error_response(:error => 'invalid_request')
    end

    access_token = find_acccess_token(:grant_type => 'client_credentials',
                                      :client => client,
                                      :scope => request['scope'])

    if access_token['error']
      error_response(access_token)
    else
      successful_response(access_token)
    end
  end

  private
  def find_acccess_token(opts)
    if @issuer
      @issuer.call(opts)
    end || { 'error' => 'unauthorized_client' }
  end

  def successful_response(response_object)
    headers = {
      'Content-Type' => 'application/json;charset=UTF-8',
      'Cache-Control' => 'no-store',
      'Pragma' => 'no-cache'
    }

    [200, headers, [MultiJson.encode(response_object)]]
  end

  def error_response(response_object)
    headers = {
      'Content-Type' => 'application/json;charset=UTF-8'
    }

    [400, headers, [MultiJson.encode(response_object)]]
  end
end
