require_relative 'marvel_api'

personaje = MarvelApi::Character.new
p personaje.all
