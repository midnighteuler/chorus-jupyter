require 'httparty'

require_relative 'versions/supported_versions'
require_relative 'exceptions'

module ChorusJupyter
  class ApiVersioner
    def initialize(h)
      @params = h

      @server_url = h[:server_url]
      @timeout = h[:timeout] || 5
      @api_version = h[:api_version] || ChorusJupyter::SUPPORTED_VERSIONS.keys.last

      use_api_version(@api_version)
    end

    def api
      return @api
    end

    def use_api_version(v)
      if !ChorusJupyter::SUPPORTED_VERSIONS.has_key?(v)
        raise ChorusJupyter::ApiVersionUnsupportedException, "API version \"#{v}\" not supported. Supported versions: #{ChorusJupyter::SUPPORTED_VERSIONS.keys.join(", ")}"
      end

      @api_version = v
      @api = ChorusJupyter::SUPPORTED_VERSIONS[v]::Api.new({
          :server_url => @server_url,
          :timeout => @timeout
      })
    end

    def api_version
      return @api_version
    end

    def server_url
      return @server_url
    end

    def fetch_server_version
      response = HTTParty.get(@server_url + '/api', timeout: @timeout)
      @remote_api_version = response["version"]
    rescue Exception => e
      raise ChorusJupyter::ApiFetchError, e.message
    end
  end
end