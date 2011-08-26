# Client authentication
module OAuth2::Rack::Authentication::Client
  autoload :HTTPBasic, 'oauth2/rack/authentication/client/http_basic'
  autoload :RequestParams, 'oauth2/rack/authentication/client/request_params'
end
