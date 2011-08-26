require 'spec_helper'

describe OAuth2::Rack::Authentication::Client::HTTPBasic do
  let(:client) { double('client').as_null_object }
  let(:authenticator) { double('authenticator').as_null_object }
  let(:opts) { Hash.new }
  let(:chained_app_response) { [200, { 'Content-Type' => 'text/plain' }, []] }

  def do_request
    post '/', opts
  end

  context 'when auth header is not specified' do
    it 'responds with 401 unauthorized' do
      do_request
      response.status.should eq(401)
    end
  end

  context 'when schema is not basic' do
    before { opts['HTTP_AUTHORIZATION'] = 'Digest xxx' }

    it 'responds with 400 bad request' do
      do_request
      response.status.should eq(400)
    end
  end

  context 'when schema is basic' do
    app {
      OAuth2::Rack::Authentication::Client::HTTPBasic.new(chained_app) do |opts|
        authenticator.call(opts)
      end
    }
    before { opts['HTTP_AUTHORIZATION'] = "Basic #{["user:pass"].pack('m*')}" }

    context 'and credentials are valid' do
      it 'sets oauth2.client in env' do
        authenticator.should_receive(:call).with(:client_id => 'user', :client_secret => 'pass').and_return(client)
        chained_app.should_receive(:call).with(hash_including('oauth2.client' => client)).and_return(chained_app_response)

        do_request
      end
    end

    context 'but credentials are invalid' do
      it 'responds with 401 unauthorized' do
        authenticator.should_receive(:call).with(:client_id => 'user', :client_secret => 'pass').and_return(nil)
        chained_app.should_not_receive(:call)

        do_request

        response.status.should eq(401)
      end
    end
  end
end
