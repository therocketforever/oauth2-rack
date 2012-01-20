# @see 6. Refreshing an access token
require 'oauth2/rack'
require 'multi_json'

class OAuth2::Rack::Authorization::RefreshToken::AccessTokenIssuer
  def initialize(app, opts = {}, &issuer)
    @app = app

    @issuer = issuer || opts[:issuer]
  end

  def call(env)
    request = Rack::Request.new(env)
    unless request['grant_type'] == 'refresh_token'
      return error_response(:error => 'invalid_request')
    end

    # oauth2.client is set in client authentication
    access_token = find_acccess_token(:grant_type => 'refresh_token',
                                      :refresh_token => request['refresh_token'],
                                      :client => env['oauth2.client'],
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
    end || { 'error' => 'invalid_grant' }
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
