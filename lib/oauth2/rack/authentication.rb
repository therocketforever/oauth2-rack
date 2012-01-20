# Middlewares for authorization server to authenticate client or user
module OAuth2::Rack::Authentication
  autoload :Client, 'oauth2/rack/authentication/client'
  autoload :ResourceOwner, 'oauth2/rack/authentication/resource_owner'
  autoload :AccessToken, 'oauth2/rack/authentication/access_token'
end

