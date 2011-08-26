# @see 4.3. Resource Owner Password Credentials
require 'oauth2/rack'
require 'multi_json'

class OAuth2::Rack::Authorization::Password::AccessTokenIssuer
  def initialize(app, opts = {}, &issuer)
    @app = app

    @issuer = issuer || opts.delete(:issuer)
  end

  def call(env)
    resource_owner = env['oauth2.resource_owner']
    unless resource_owner
      return error_response(:error => 'invalid_grant')
    end

    request = Rack::Request.new(env)
    unless request['grant_type'] == 'password'
      return error_response(:error => 'invalid_request')
    end

    # oauth2.client is set in client authentication
    access_token = find_acccess_token(:grant_type => 'password',
                                      :resource_owner => resource_owner,
                                      :client => env['oath2.client'],
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
