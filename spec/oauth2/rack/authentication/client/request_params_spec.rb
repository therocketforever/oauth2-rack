require 'spec_helper'

describe OAuth2::Rack::Authentication::Client::RequestParams do
  let(:client) { double('client').as_null_object }
  let(:authenticator) { double('authenticator').as_null_object }
  let(:params) { Hash.new }
  let(:opts) { Hash[:params => params] }
  let(:chained_app_response) { [200, { 'Content-Type' => 'text/plain' }, []] }

  def do_request
    post '/', opts
  end

  context 'when oauth2.client is already set' do
    it 'continues the app' do
      opts['oauth2.client'] = client
      chained_app.should_receive(:call).with(hash_including('oauth2.client' => client)).and_return(chained_app_response)
      do_request
      response.status.should eq(200)
    end
  end

  context 'when client_id and client_secret are both missed' do
    context 'and request params auth is required' do
      it 'responds with 401 unauthorized' do
        do_request
        response.status.should eq(401)
      end
    end
    context 'and request params auth is optional' do
      app { OAuth2::Rack::Authentication::Client::RequestParams.new(chained_app, :required => false) }
      it 'continues the app' do
        chained_app.should_receive(:call).with(hash_not_including('oauth2.client')).and_return(chained_app_response)
        do_request
        response.status.should eq(200)
      end
    end
  end

  context 'when client_id is missed' do
    before { params['client_secret'] = 'secret' }

    it 'responds with 400 bad request' do
      do_request
      response.status.should eq(400)
    end
  end
  context 'when client_secret is missed' do
    before { params['client_id'] = 'client_x' }

    it 'responds with 400 bad request' do
      do_request
      response.status.should eq(400)
    end
  end

  context 'when client_id and client_secret are specified' do
    app {
      OAuth2::Rack::Authentication::Client::RequestParams.new(chained_app) do |opts|
        authenticator.call(opts)
      end
    }
    let(:credentials) { Hash[:client_id => 'client_x', :client_secret => 'secret'] }
    before { params.merge! credentials }

    context 'and credentials are valid' do
      it 'sets oauth2.client in env' do
        authenticator.should_receive(:call).with(credentials).and_return(client)
        chained_app.should_receive(:call).with(hash_including('oauth2.client' => client)).and_return(chained_app_response)

        do_request
      end
    end

    context 'but credentials are invalid' do
      it 'responds with 401 unauthorized' do
        authenticator.should_receive(:call).with(credentials).and_return(nil)
        chained_app.should_not_receive(:call)

        do_request

        response.status.should eq(401)
      end
    end
  end
end
