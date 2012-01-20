require 'oauth2/rack'

# Authenticate resource owner with request params
class OAuth2::Rack::Authentication::ResourceOwner::RequestParams
  def initialize(app, opts = {}, &authenticator)
    @app = app
    @required = opts.fetch(:required, true)
    @authenticator = authenticator || opts[:authenticator]
  end

  def call(env)
    return @app.call(env) if env.has_key?('oauth2.resource_owner')

    @request = Rack::Request.new(env)

    username = @request['username']
    password = @request['password']
    if username.nil? && password.nil?
      return @required ? unauthorized : @app.call(env)
    elsif username.nil? || password.nil?
      return bad_request
    end

    credentials = {
      :username => username,
      :password => password
    }
    credentials[:client] = env['oauth2.client'] if env['oauth2.client']
    resource_owner = @authenticator.call credentials

    if resource_owner
      env['oauth2.resource_owner'] = resource_owner
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
        'Content-Length' => '0' },
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
