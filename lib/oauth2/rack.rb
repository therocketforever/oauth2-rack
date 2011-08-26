require 'oauth2/rack/version'

module OAuth2
  # Oauth2::Rack module, the top namespace for all oauth2-rack modules and classes
  module Rack
    autoload :Authorization, 'oauth2/rack/authorization'
    autoload :Authentication, 'oauth2/rack/authentication'
  end
end
