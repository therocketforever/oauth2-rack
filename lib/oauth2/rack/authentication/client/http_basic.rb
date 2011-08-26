require 'oauth2/rack'

# 2.4.1. Client Password
class OAuth2::Rack::Authentication::Client::HTTPBasic
  HEADER_KEYS = ['HTTP_AUTHORIZATION', 'X-HTTP_AUTHORIZATION', 'X_HTTP_AUTHORIZATION']

  def initialize(app, opts = {}, &authenticator)
    @app = app
    @realm = opts.delete(:realm)
    @required = opts.fetch(:required, true)
    opts.delete(:required)
    @authenticator = authenticator || opts.delete(:authenticator)
  end

  def call(env)
    return @app.call(env) if env.has_key?('oauth2.client')

    key = HEADER_KEYS.find { |k| env.has_key?(k) }
    auth_string = env[key]

    if auth_string.nil?
      return @required ? unauthorized : @app.call(env)
    end

    schema, credentials = auth_string.split(' ', 2)
    if schema.downcase != 'basic'
      return bad_request
    end

    client_id, client_secret = credentials.unpack('m*').first.split(':', 2)
    client = @authenticator.call(:client_id => client_id, :client_secret => client_secret)
    if client
      env['oauth2.client'] = client
      @app.call(env)
    else
      unauthorized
    end
  end

  private
  def authenticate(opts)
    @authenticator && @authenticator.call(opts)
  end

  def unauthorized
    [ 401,
      { 'Content-Type' => 'text/plain',
        'Content-Length' => '0',
        'WWW-Authenticate' => 'Basic realm="%s"' % @realm },
      []
    ]
  end

  def bad_request
    [ 400,
      { 'Content-Type' => 'text/plain',
        'Content-Length' => '0' },
      []
    ]
  end
end
