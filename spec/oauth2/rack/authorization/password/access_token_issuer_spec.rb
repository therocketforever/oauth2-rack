require 'spec_helper'

describe OAuth2::Rack::Authorization::Password::AccessTokenIssuer do
  let(:resource_owner) { double('resource_owner') }
  let(:client) { double('client') }
  let(:opts) { Hash.new }

  def do_request
    post '/', opts
  end

  context 'when resource_owner is authenticated' do
    before { opts['oauth2.resource_owner'] = resource_owner }

    context 'and grant_type is invalid' do
      let(:params) { Hash[:grant_type => 'xpassword'] }
      before { opts[:params] = params }

      it 'responds with invalid_request' do
        do_request

        response.status.should eq(400)
        response_object['error'].should eq('invalid_request')
      end
    end

    context 'and grant_type is valid' do
      let(:params) { Hash[:grant_type => 'password'] }
      before { opts[:params] = params }

      context 'and issuer is not specified' do
        it 'responds with unauthorized_client' do
          do_request

          response.status.should eq(400)
          response_object['error'].should eq('unauthorized_client')
        end
      end

      context 'and issuer is specified' do
        let(:issuer) { double('issuer') }
        let(:expected_find_opts) {
          Hash[:grant_type => 'password',
               :resource_owner => resource_owner,
               :client => nil,
               :scope => nil]
        }

        app { OAuth2::Rack::Authorization::Password::AccessTokenIssuer.new(chained_app) { |opts| issuer.call(opts) } }

        context 'but token is not found for the resource owner' do
          context 'and error is returned' do
            before {
              issuer.should_receive(:call).with(expected_find_opts).and_return({'error' => 'customized_error'})
            }
            it 'responds with the that error' do
              do_request

              response.status.should eq(400)
              response_object['error'].should eq('customized_error')
            end
          end
          context 'and nothing is returned' do
            before {
              issuer.should_receive(:call).with(expected_find_opts).and_return(nil)
            }
            it 'responds with unauthorized_client' do
              do_request

              response.status.should eq(400)
              response_object['error'].should eq('unauthorized_client')
            end
          end
          
        end
        context 'and token is found for the client' do
          before {
            issuer.should_receive(:call).with(expected_find_opts).and_return({:access_token => 'X'})
          }

          it 'responds with the found token' do
            do_request

            response.status.should eq(200)
            response_object['access_token'].should eq('X')
          end
        end
      end
    end

  end

  context 'when resource owner not authenticated' do
    before { post '/' }

    it 'responds with invalid_grant' do
      response.status.should eq(400)
      response_object['error'].should eq('invalid_grant')
    end
  end
end
