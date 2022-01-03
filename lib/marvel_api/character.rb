# frozen_string_literal: true

module MarvelApi
  # This class handles requests for Marvel characters
  class Character
    def initialize
      @base = Base.new('/characters', records_per_page: 5)
    end

    def all(filters = '')
      list(filters: filters)
    end

    def find(id)
      base.get(params: { id: id })
    end

    def comics(id)
      list(id: id, route: 'comics')
    end

    def events(id)
      list(id: id, route: 'events')
    end

    def series(id)
      list(id: id, route: 'series')
    end

    def stories(id)
      list(id: id, route: 'stories')
    end

    private

    attr_reader :base

    def list(**args)
      params = {}

      params.store(:filters, args[:filters]) if args.key?(:filters)
      params.store(:id, args[:id]) if args.key?(:id)
      params.store(:route, args[:route]) if args.key?(:route)

      recordset = base.get(params: params)

      if recordset[:pages]&.positive?
        data = []
        data.insert(0, recordset[:results])

        if recordset[:pages] > 1
          (2..recordset[:pages])
            .map do |page|
              current_page = page - 1
              new_offset = current_page * base.records_per_page

              Thread.new do
                data[current_page] = paginate(new_offset, params)[:results]
              end
            end
            .map(&:value)
        end

        data
      else
        recordset
      end
    end

    def paginate(offset, params)
      base.get(offset: offset, params: params)
    end
  end
end
