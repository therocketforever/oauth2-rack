require 'spec_helper'

describe OAuth2::Rack::Authentication::AccessToken::BearerHeader do
  let(:access_token) { 'xxx' }
  let(:authenticator) { double('authenticator').as_null_object }
  let(:opts) { Hash.new }
  let(:chained_app_response) { [200, { 'Content-Type' => 'text/plain' }, []] }

  def do_request
    post '/', opts
  end

  context 'when auth header is not specified' do
    context 'and bearer auth is required' do
      it 'responds with 401 unauthorized' do
        do_request
        response.status.should eq(400)
      end
    end
    context 'and http basic auth is optional' do
      app { OAuth2::Rack::Authentication::AccessToken::BearerHeader.new(chained_app, :required => false) }
      it 'continues the app' do
        chained_app.should_receive(:call).and_return(chained_app_response)
        do_request
        response.status.should eq(200)
      end
    end
  end

  context 'when schema is not bearer' do
    before { opts['HTTP_AUTHORIZATION'] = 'Digest ' + access_token }

    it 'responds with 400 bad request' do
      do_request
      response.status.should eq(400)
    end
  end

  context 'when schema is bearer' do
    app {
      OAuth2::Rack::Authentication::AccessToken::BearerHeader.new(chained_app) do |opts|
        authenticator.call(opts)
      end
    }
    before { opts['HTTP_AUTHORIZATION'] = "Bearer #{access_token}" }

    context 'and credentials are valid' do
      it 'sets oauth2.client in env' do
        authenticator.should_receive(:call).with(:access_token => access_token).and_return(access_token)
        chained_app.should_receive(:call).with(hash_including('oauth2.access_token' => access_token)).and_return(chained_app_response)

        do_request
      end
    end

    context 'but credentials are invalid' do
      it 'responds with 401 unauthorized' do
        authenticator.should_receive(:call).with(:access_token => access_token).and_return(nil)
        chained_app.should_not_receive(:call)

        do_request

        response.status.should eq(401)
      end
    end
  end
end
