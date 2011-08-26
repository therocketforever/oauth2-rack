require 'spec_helper'

describe OAuth2::Rack::Authentication::ResourceOwner::RequestParams do
  let(:resource_owner) { double('resource_owner').as_null_object }
  let(:authenticator) { double('authenticator').as_null_object }
  let(:params) { Hash.new }
  let(:opts) { Hash[:params => params] }
  let(:chained_app_response) { [200, { 'Content-Type' => 'text/plain' }, []] }

  def do_request
    post '/', opts
  end

  context 'when oauth2.resource_owner is already set' do
    it 'continues the app' do
      opts['oauth2.resource_owner'] = resource_owner
      chained_app.should_receive(:call).with(hash_including('oauth2.resource_owner' => resource_owner)).and_return(chained_app_response)
      do_request
      response.status.should eq(200)
    end
  end

  context 'when username and password are both missed' do
    context 'and request params auth is required' do
      it 'responds with 401 unauthorized' do
        do_request
        response.status.should eq(401)
      end
    end
    context 'and request params auth is optional' do
      app { OAuth2::Rack::Authentication::ResourceOwner::RequestParams.new(chained_app, :required => false) }
      it 'continues the app' do
        chained_app.should_receive(:call).with(hash_not_including('oauth2.resource_owner')).and_return(chained_app_response)
        do_request
        response.status.should eq(200)
      end
    end
  end

  context 'when username is missed' do
    before { params['password'] = 'secret' }

    it 'responds with 400 bad request' do
      do_request
      response.status.should eq(400)
    end
  end
  context 'when password is missed' do
    before { params['username'] = 'user_x' }

    it 'responds with 400 bad request' do
      do_request
      response.status.should eq(400)
    end
  end

  context 'when username and password are specified' do
    app {
      OAuth2::Rack::Authentication::ResourceOwner::RequestParams.new(chained_app) do |opts|
        authenticator.call(opts)
      end
    }
    let(:credentials) { Hash[:username => 'user_x', :password => 'secret'] }
    before { params.merge! credentials }

    context 'and credentials are valid' do
      it 'sets oauth2.resource_owner in env' do
        authenticator.should_receive(:call).with(credentials).and_return(resource_owner)
        chained_app.should_receive(:call).with(hash_including('oauth2.resource_owner' => resource_owner)).and_return(chained_app_response)

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
