# Middlewares for authorization server
module OAuth2::Rack::Authorization::ClientCredentials
  autoload :AccessTokenIssuer, 'oauth2/rack/authorization/client_credentials/access_token_issuer'
end

