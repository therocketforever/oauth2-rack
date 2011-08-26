require 'oauth2'

client = OAuth2::Client.new('client_id', 'client_secret', :site => 'http://localhost:9393/', :token_url => '/password/access_token')
token = client.password.get_token('username', 'password')

p token
