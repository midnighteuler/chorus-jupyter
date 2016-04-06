require_relative '../../../chorus_jupyter/exceptions'
require_relative '../interface'

module ChorusJupyter
  module V4_1_0
    # Handles api as described in https://github.com/jupyter/notebook/blob/master/notebook/services/api/api.yaml (for 4.1.0)
    class Api < ChorusJupyter::Api
      def initialize(h)
        @server_url = h[:server_url]
        @timeout = h[:timeout]
      end

      # Directory handling:
      def create_directory(directory)
        # 4.1.0 seems to require that you create a folder with one request,
        # (it names the folder something like "Untitled Folder 2")
        # then you issue another request to update it to a meaningful name.
        # Just having ":path => 'whatever'" in the body of the first call won't name it.
        new_dir = HTTParty.post(URI.encode("#{@server_url}/api/contents"), {
            :body => { :type => "directory" }.to_json,
            :timeout => @timeout
        })
        #puts new_dir

       return rename_directory(new_dir['path'], directory)
      rescue Exception => e
        raise ChorusJupyter::ApiFetchError, e.message
      end

      def rename_directory(directory, new_path)
        rename_dir = HTTParty.patch(URI.encode("#{@server_url}/api/contents/#{directory}"), {
            :body => { :path => new_path }.to_json,
            :timeout => @timeout
        })
        #puts rename_dir

        return rename_dir
      rescue Exception => e
        raise ChorusJupyter::ApiFetchError, e.message
      end

      # Notebook file handling
      def create_notebook(filename, base_dir='')
        new_nb = HTTParty.post(URI.encode("#{@server_url}/api/contents/#{base_dir}"), {
            :body => { :type => "notebook" }.to_json,
            :timeout => @timeout
        })
        #puts new_nb

        return rename_notebook(new_nb['name'], filename, base_dir)
      rescue Exception => e
        raise ChorusJupyter::ApiFetchError, e.message
      end

      def rename_notebook(filename, new_filename, base_dir='')
        nb_path = base_dir.length > 0 ? "#{base_dir}/#{filename}" : "#{filename}"

        renamed_nb = HTTParty.patch(URI.encode("#{@server_url}/api/contents/#{nb_path}"), {
            :body => { :path => "#{base_dir}/#{new_filename}" }.to_json,
            :timeout => @timeout
        })
        # puts renamed_nb

        return renamed_nb
      rescue Exception => e
        raise ChorusJupyter::ApiFetchError, e.message
      end

      def get_notebook_contents(path, format='text')
        file_description = HTTParty.get(URI.encode("#{@server_url}/api/contents/#{path}?content=1&type=file&format=#{format}"), {
            :timeout => @timeout
        })

        # On doesn't exist, expect something like:
        # {
        #     "reason": null,
        #     "message": "No such file or directory: this_shouldnt_exist.ipynb"
        # }
        # Else expect something like:
        # {"mimetype"=>nil, "writable"=>true, "name"=>"test_notebook.ipynb", "format"=>nil, "created"=>"2016-04-06T00:27:45+00:00", "content"=>nil, "last_modified"=>"2016-04-06T00:27:45+00:00", "path"=>"test_notebook.ipynb", "type"=>"file"}
        return nil if file_description.has_key?('message')

        file_description
      rescue Exception => e
        raise ChorusJupyter::ApiFetchError, e.message
      end

      def notebook_or_directory_exists(path)
        file_description = HTTParty.get(URI.encode("#{@server_url}/api/contents/#{path}?content=0"), {
            :timeout => @timeout
        })

        return false if file_description.has_key?('message')

        file_description
      rescue Exception => e
        raise ChorusJupyter::ApiFetchError, e.message
      end

      # Note: format != 'text' seems to fail in 4.1.0.
      def upload_notebook(notebook_name, path, contents, format='text')
        file_upload = HTTParty.put(URI.encode("#{@server_url}/api/contents/#{path}"), {
            :body => {
                :name => notebook_name,
                :type => 'file',
                :path => path,
                :format => format,
                :content => contents
            }.to_json,
            :timeout => @timeout
        })

        return nil if file_upload.has_key?('message')

        file_upload
      rescue Exception => e
        raise ChorusJupyter::ApiFetchError, e.message
      end

      def delete_notebook(path)
        file_delete = HTTParty.delete(URI.encode("#{@server_url}/api/contents/#{path}"), {
            :body => {
                :path => path
            }.to_json,
            :timeout => @timeout
        })

        return file_delete.code == 204
      rescue Exception => e
        raise ChorusJupyter::ApiFetchError, e.message
      end
    end
  end
end