module MarvelApi
  class Character
    def initialize
      @base = Base.new
      @base.endpoint = '/characters'
    end

    def all
      @base.get
    end

    def find(id)
      @base.get(filters: id)
    end

    def comics(id)
      @base.get(filters: id, route: 'comics')
    end

    def events(id)
      @base.get(filters: id, route: 'events')
    end

    def series(id)
      @base.get(filters: id, route: 'series')
    end

    def stories(id)
      @base.get(filters: id, route: 'stories')
    end
  end
end
