require 'contractual'
module ChorusJupyter
  class Api
    include Contractual::Interface

    must :create_directory, :directory
    must :rename_directory, :directory, :new_path
    must :directory_exists, :directory


    must :create_notebook, :file_name, :base_dir
    must :rename_notebook, :file_name, :new_file_name
    must :upload_notebook, :destination_filename, :contents
    must :notebook_exists, :file_name
  end
end