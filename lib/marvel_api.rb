# frozen_string_literal: true

require_relative 'marvel_api/version'
require_relative 'marvel_api/base'
require_relative 'marvel_api/character'

module MarvelApi
  class Error < StandardError
  end

  def self.characters(filters = 'nameStartsWith=black')
    Character.new.all(filters)
  end

  def self.character(id)
    Character.new.find(id)
  end

  def self.comics(id)
    Character.new.comics(id)
  end

  def self.events(id)
    Character.new.events(id)
  end

  def self.series(id)
    Character.new.series(id)
  end

  def self.stories(id)
    Character.new.stories(id)
  end
end
