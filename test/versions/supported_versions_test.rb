gem 'minitest'
require 'minitest/autorun'

require_relative  '../../chorus_jupyter/versions/supported_versions'
class TestSupportedVersions < Minitest::Test
  def setup
    @supported_versions = ChorusJupyter::SUPPORTED_VERSIONS
  end

  def test_supported_versions_has_expected_structure
    # Expect supported versions to be a hash mapping version strings to modules
    @supported_versions.each do |k,v|
      assert_equal k.is_a?(String), true
      assert_equal v.class.is_a?(Module), true
    end

    assert_equal @supported_versions['invalid_version'].nil?, true
  end
end