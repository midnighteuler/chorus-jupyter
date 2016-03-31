require_relative '../../../chorus_jupyter/exceptions'
require_relative '../interface'

module ChorusJupyter
  module V4_1_0
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

      #def directory_exists(directory)
      #rescue Exception => e
      #  raise ChorusJupyter::ApiFetchError, e.message
      #end

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

      #def upload_notebook(destination_filename, contents)
      #rescue Exception => e
      #  raise ChorusJupyter::ApiFetchError, e.message
      #end

      def rename_notebook(filename, new_filename, base_dir='')
        old_path = base_dir.length > 0 ? "#{base_dir}/#{filename}" : "#{filename}"

        renamed_nb = HTTParty.patch(URI.encode("#{@server_url}/api/contents/#{old_path}"), {
            :body => { :path => "#{base_dir}/#{new_filename}" }.to_json,
            :timeout => @timeout
        })
        # puts renamed_nb

        return renamed_nb
      rescue Exception => e
        raise ChorusJupyter::ApiFetchError, e.message
      end

      #def notebook_exists(filename)
      #rescue Exception => e
      #  raise ChorusJupyter::ApiFetchError, e.message
      #end
    end
  end
end