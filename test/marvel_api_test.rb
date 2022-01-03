# frozen_string_literal: true

require 'test_helper'

class MarvelApiTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::MarvelApi::VERSION
  end

  def test_fetch_all_characters
    VCR.use_cassette('characters') do
      assert_instance_of Array, MarvelApi.characters
      assert_instance_of Hash, MarvelApi.characters.dig(0, 0)
    end
  end

  def test_fetch_character
    VCR.use_cassette('character') do
      assert_instance_of Hash, MarvelApi.character(1_010_743)
      assert_equal 'Groot', MarvelApi.character(1_010_743)[:name]
    end
  end

  def test_fecth_events
    VCR.use_cassette('events') do
      assert_instance_of Array, MarvelApi.events(1_016_181)
      assert_instance_of Hash, MarvelApi.events(1_016_181).dig(0, 0)
      assert_equal 'Secret Empire',
                   MarvelApi.events(1_016_181).dig(0, 0, :title)
    end
  end

  def test_fecth_series
    VCR.use_cassette('series') do
      assert_instance_of Array, MarvelApi.series(1_010_743)
      assert_instance_of Hash, MarvelApi.series(1_010_743).dig(0, 0)
      assert_equal 'Annihilation: Conquest - Starlord (2007)',
                   MarvelApi.series(1_010_743).dig(0, 0, :title)
    end
  end

  def test_fecth_stories
    VCR.use_cassette('stories') do
      assert_instance_of Array, MarvelApi.stories(1_010_743)
      assert_instance_of Hash, MarvelApi.stories(1_010_743).dig(0, 0)
      assert_equal 'Annihilation Conquest: Starlord (2007) #1',
                   MarvelApi.stories(1_010_743).dig(0, 0, :title)
    end
  end
end
