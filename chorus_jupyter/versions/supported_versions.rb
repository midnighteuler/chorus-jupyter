require_relative 'V4_1_0/api'

module ChorusJupyter
  # Supported Jupyter versions.
  # Last element serves as default.
  SUPPORTED_VERSIONS = {
    '4.1.0' => ChorusJupyter::V4_1_0
  }
end