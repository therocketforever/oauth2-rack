require 'oauth2/rack'

# 7. Accessing Protected Resources
class OAuth2::Rack::Authentication::AccessToken::BearerHeader
  HEADER_KEYS = ['HTTP_AUTHORIZATION', 'X-HTTP_AUTHORIZATION', 'X_HTTP_AUTHORIZATION']

  def initialize(app, opts = {}, &authenticator)
    @app = app
    @realm = opts[:realm]
    @required = opts.fetch(:required, true)
    @authenticator = authenticator || opts[:authenticator]
  end

  def call(env)
    key = HEADER_KEYS.find { |k| env.has_key?(k) }
    auth_string = env[key]

    if auth_string.nil?
      return @required ? error_response('code' => 400, 'error' => 'invalid_request') : @app.call(env)
    end

    schema, credentials = auth_string.split(' ', 2)
    if schema.downcase != 'bearer'
      return error_response('code' => 400,
                            'error' => 'invalid_request')
    end

    access_grant = @authenticator.call(:access_token => credentials)

    if access_grant.nil? || (access_grant.is_a?(Hash) && access_grant[:error])
      error_response(access_grant)
    else
      env['oauth2.access_grant'] = access_grant
      @app.call(env)
    end
  end

  private
  def authenticate(opts)
    @authenticator && @authenticator.call(opts)
  end

  def error_response(opts)
    opts ||= {}
    code = opts.delete('code') || 401

    opts['realm'] = @realm if @realm
    opts['error'] ||= 'invalid_token'

    [ code,
      { 'Content-Type' => 'text/plain',
        'Content-Length' => '0',
        'WWW-Authenticate' => www_authenticate_header(opts) },
      []
    ]
  end

  def www_authenticate_header(opts)
    'Bearer ' + opts.collect { |k, v| %Q(#{k}=#{v.inspect})  }.join(',')
  end
end
