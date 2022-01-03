# frozen_string_literal: true

require 'test_helper'

module MarvelApi
  class MarvelApiTest < Minitest::Test
    def test_base_class_exist
      refute_nil Base.new
    end
  end
end
