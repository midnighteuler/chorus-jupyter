require 'contractual'
module ChorusJupyter
  class Api
    include Contractual::Interface

    must :create_directory, :directory
    must :rename_directory, :directory, :new_path

    must :create_notebook, :file_name, :base_dir
    must :rename_notebook, :file_name, :new_file_name
    must :delete_notebook, :path
    must :get_notebook_contents, :path, :format
    must :upload_notebook, :destination_filename, :contents

    must :notebook_or_directory_exists, :path
  end
end