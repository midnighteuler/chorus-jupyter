gem 'minitest'
require 'minitest/autorun'

require_relative  '../../chorus_jupyter/versions/interface'

class TestUsesInterface < Minitest::Test
  class IncompleteAPI < ChorusJupyter::Api; end

  def test_interface_requires_methods
    c = IncompleteAPI.new

    assert_raises Contractual::Interface::MethodNotImplementedError do
      c.file_exists('some_path')
    end
  end
end