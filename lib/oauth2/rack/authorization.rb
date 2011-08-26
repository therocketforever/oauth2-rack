# Middlewares for authorization server
module OAuth2::Rack::Authorization
  autoload :ClientCredentials, 'oauth2/rack/authorization/client_credentials'
  autoload :Password, 'oauth2/rack/authorization/password'
end

