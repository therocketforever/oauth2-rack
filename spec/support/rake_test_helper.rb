require 'rack/mock'
require 'rack/utils'

module RackTestHelper
  def self.included(klass)
    klass.extend ClassMethods
  end

  attr_accessor :response

  def chained_app
    if defined?(@original_chained_app)
      @original_chained_app
    else
      @original_chained_app = instance_eval(&self.class.chained_app)
    end
  end
  
  def app
    if defined?(@original_app)
      @original_app
    else
      @original_app = instance_eval(&self.class.app)
    end
  end

  def request
    @request ||= Rack::MockRequest.new(app)
  end

  def response_object
    return unless response

    case response['Content-Type']
    when %r{^application/json}
      MultiJson::decode(response.body)
    when %r{^application/x-www-form-urlencoded}
      Rack::Utils.new.parse(response.body)
    else
      response.body
    end
  end

  def get(uri, opts = {})
    self.response = request.get(uri, opts)
  end
  def post(uri, opts = {})
    self.response = request.post(uri, opts)
  end
  def put(uri, opts = {})
    self.response = request.put(uri, opts)
  end
  def delete(uri, opts = {})
    self.response = request.delete(uri, opts)
  end

  module ClassMethods
    attr_reader :explicit_chained_app_block
    def chained_app(&block)
      block ? @explicit_chained_app_block = block : explicit_chained_app || implicit_chained_app
    end

    attr_reader :explicit_app_block
    def app(&block)
      block ? @explicit_app_block = block : explicit_app || implicit_app
    end

    def explicit_app
      group = self
      while group.respond_to?(:explicit_app_block)
        return group.explicit_app_block if group.explicit_app_block
        group = group.superclass
      end
    end

    def implicit_app
      described = describes || description
      Class === described ? proc { described.new(chained_app) } : proc { described }
    end

    def explicit_chained_app
      group = self
      while group.respond_to?(:explicit_chained_app_block)
        return group.explicit_chained_app_block if group.explicit_chained_app_block
        group = group.superclass
      end
    end

    def implicit_chained_app
      proc { |env| [200, {"Content-Type" => 'text/html'}, ["<p>OK</p>"]] }
    end
  end
end

RSpec.configure do |config|
  config.include RackTestHelper
end
