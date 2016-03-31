TEST_SERVER_PARAMS = {
    '4.1.0' => {
        :server_url => 'http://127.0.0.1:8888'
    }
}

gem 'minitest'
require 'minitest/autorun'
require 'webmock/minitest'
require 'vcr'

require_relative '../chorus_jupyter/api_versioner'
VCR.configure do |c|
  c.cassette_library_dir = 'fixtures/vcr_cassettes'
  c.hook_into :webmock
  c.allow_playback_repeats = true
end

describe ChorusJupyter::ApiVersioner do
  describe "fetching version and yielding appropriate API" do
    before do
      @latest_supported_version = ChorusJupyter::SUPPORTED_VERSIONS.keys.last # '4.1.0'
      @valid_params = TEST_SERVER_PARAMS[@latest_supported_version]
    end

    it "sends a GET request server to determine API version" do
      VCR.use_cassette('fetch_version_' + @latest_supported_version) do
        t = ChorusJupyter::ApiVersioner.new(@valid_params)

        t.fetch_server_version.must_equal @latest_supported_version
       end
    end

    it "uses the latest API version if one isn't provided" do
      t = ChorusJupyter::ApiVersioner.new(@valid_params)
      t.api_version.must_equal @latest_supported_version
    end

    it "raises ApiVersionUnsupportedException for unsupported API version" do
      assert_raises ChorusJupyter::ApiVersionUnsupportedException do
        ChorusJupyter::ApiVersioner.new({ :api_version => 'some unknown version' })
      end
    end

    it "respects timeout" do
      t = ChorusJupyter::ApiVersioner.new(@valid_params)
      stub_request(:get, t.server_url + '/api').to_timeout

      err = assert_raises ChorusJupyter::ApiFetchError do
        t.fetch_server_version
      end

      assert_match /execution expired/, err.message
    end
  end
end
