require 'oauth2/rack'

# 2.4.1. Client Password
# Send client_id and client_secret in request params
class OAuth2::Rack::Authentication::Client::RequestParams
  def initialize(app, opts = {}, &authenticator)
    @app = app
    @authenticator = authenticator
  end

  def call(env)
    @request = Rack::Request.new(env)

    client_id = @request['client_id']
    client_secret = @request['client_secret']
    if client_id.nil? && client_secret.nil?
      return unauthorized
    elsif client_id.nil? || client_secret.nil?
      return bad_request
    end

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
