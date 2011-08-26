# Middlewares for authorization server
module OAuth2::Rack::Authorization::Password
  autoload :AccessTokenIssuer, 'oauth2/rack/authorization/password/access_token_issuer'
end

