TEST_SERVER_PARAMS = {
    '4.1.0' => {
        :server_url => 'http://127.0.0.1:8888'
    }
}

gem 'minitest'
require 'minitest/autorun'
require 'webmock/minitest'
require 'vcr'

require_relative '../../chorus_jupyter/api_versioner'
VCR.configure do |c|
  c.cassette_library_dir = 'fixtures/vcr_cassettes'
  c.hook_into :webmock
  c
end

describe ChorusJupyter::V4_1_0::Api do
  describe "interacting with directories and notebooks" do
    before do
      @version = '4.1.0'
      @valid_params = TEST_SERVER_PARAMS[@version]
      @api = ChorusJupyter::ApiVersioner.new(@valid_params).api
    end

    it "can create and rename a directory" do
      VCR.use_cassette('create_and_rename_directory_' + @version) do
        new_dir_name = 'test_directory'
        create_attempt = @api.create_directory(new_dir_name)

        # Expect something like:
        #{
        #    "mimetype"   =>nil,
        #    "writable"   =>true,
        #    "name"   =>"new_dir_name",
        #    "format"   =>nil,
        #    "created"   =>"2016-03-31T04:11:19+00:00   ", "   content"=>nil,
        #    "last_modified"   =>"2016-03-31T04:11:19+00:00   ", "   path"=>"Untitled Folder",
        #    "type"   =>"directory"
        #}
        ['mimetype', 'writable', 'name', 'format', 'created', 'last_modified', 'type'].each do |k|
          create_attempt.has_key?(k).must_equal true
        end

        # Needs to be a directory type
        create_attempt['type'].must_equal 'directory'

        # Name needs to match
        create_attempt['name'].must_equal new_dir_name
      end
    end

    it "can create and rename a notebook" do
      VCR.use_cassette('create_and_rename_notebook_' + @version) do
        new_file_name = 'test_notebook.ipynb'
        if @api.notebook_or_directory_exists(new_file_name)
          @api.delete_notebook(new_file_name)
        end

        create_attempt = @api.create_notebook(new_file_name)
        # Expect something like:
        #{
        #    "mimetype":null,
        #    "writable":true,
        #    "name":"test_notebook.ipynb",
        #    "format":null,
        #    "created":"2016-03-31T05:48:51+00:00",
        #    "content":null,
        #    "last_modified":"2016-03-31T05:48:51+00:00",
        #    "path":"test_notebook.ipynb",
        #    "type":"notebook"
        #}
        ['mimetype', 'writable', 'name', 'format', 'created', 'content', 'last_modified', 'type'].each do |k|
          create_attempt.has_key?(k).must_equal true
        end

        # Needs to be a notebook type
        create_attempt['type'].must_equal 'notebook'

        # Name needs to match
        create_attempt['name'].must_equal new_file_name
      end
    end

    it "can check if a notebook or directory exists" do
      VCR.use_cassette('notebook_exists_' + @version) do
        doesnt_exist = 'this_shouldnt_exist.ipynb'
        if @api.notebook_or_directory_exists(doesnt_exist)
          @api.delete_notebook(doesnt_exist)
        end

        exists_attempt = @api.notebook_or_directory_exists(doesnt_exist)
        exists_attempt.must_equal false

        new_file_name = 'test_notebook.ipynb'
        @api.create_notebook(new_file_name)

        exists_attempt = @api.notebook_or_directory_exists(new_file_name)
        ['mimetype', 'writable', 'name', 'format', 'created', 'content', 'last_modified', 'type'].each do |k|
          exists_attempt.has_key?(k).must_equal true
        end
      end
    end

    it "can get the contents of a notebook" do
      VCR.use_cassette('get_notebook_contents_' + @version) do
        doesnt_exist = 'this_shouldnt_exist.ipynb'
        if @api.notebook_or_directory_exists(doesnt_exist)
          @api.delete_notebook(doesnt_exist)
        end

        exists_attempt = @api.get_notebook_contents(doesnt_exist)
        exists_attempt.nil?.must_equal true

        new_file_name = 'test_notebook.ipynb'
        @api.create_notebook(new_file_name)

        content_attempt = @api.get_notebook_contents(new_file_name, format='text')
        ['mimetype', 'writable', 'name', 'format', 'created', 'content', 'last_modified', 'type'].each do |k|
          content_attempt.has_key?(k).must_equal true
        end
        content_attempt['content'].must_equal "{\n \"cells\": [],\n \"metadata\": {},\n \"nbformat\": 4,\n \"nbformat_minor\": 0\n}\n"

        content_attempt = @api.get_notebook_contents(new_file_name, format='base64')
        ['mimetype', 'writable', 'name', 'format', 'created', 'content', 'last_modified', 'type'].each do |k|
          content_attempt.has_key?(k).must_equal true
        end
        content_attempt['content'].must_equal "ewogImNlbGxzIjogW10sCiAibWV0YWRhdGEiOiB7fSwKICJuYmZvcm1hdCI6IDQsCiAibmJmb3Jt\nYXRfbWlub3IiOiAwCn0K\n"
      end
    end

    it "can upload a notebook" do
      VCR.use_cassette('upload_notebook_' + @version) do
        uploaded_file_name = 'uploaded_notebook.ipynb'
        if @api.notebook_or_directory_exists(uploaded_file_name)
          @api.delete_notebook(uploaded_file_name)
        end

        contents = "{\n \"cells\": [],\n \"metadata\": { \"testing\": 1 },\n \"nbformat\": 4,\n \"nbformat_minor\": 0\n}\n"

        upload_attempt = @api.upload_notebook(uploaded_file_name, uploaded_file_name, contents)
        ['mimetype', 'writable', 'name', 'format', 'created', 'content', 'last_modified', 'type'].each do |k|
          upload_attempt.has_key?(k).must_equal true
        end
      end
    end
  end
end
