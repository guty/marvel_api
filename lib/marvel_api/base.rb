# frozen_string_literal: true

require 'net/http'
require 'digest'
require 'json'

module MarvelApi
  # This class proccess API requests and responses
  class Base
    BASE_URL = 'https://gateway.marvel.com/v1/public'

    API_PUBLIC_KEY = '8cd912e48edb1f92f33a672aaca82dda'
    API_PRIVATE_KEY = '811d7e28093bb09800fd1ddafa7ba191ade52010'
    RECORDS_PER_PAGE = 20.0

    attr_reader :records_per_page

    def initialize(endpoint = '', **kargs)
      @endpoint = endpoint
      @paginate = true
      @params = ''
      @offset = 0

      @records_per_page =
        if kargs.key?(:records_per_page)
          kargs[:records_per_page].to_f
        else
          RECORDS_PER_PAGE
        end
    end

    def get(**kargs)
      get_response(kargs)
    end

    private

    attr_reader :endpoint
    attr_accessor :paginate, :params, :offset

    def get_response(args)
      uri = URI(api_url(args))
      uri.query = URI.encode_www_form(proccess_params)

      proccess_response(uri)
    end

    def proccess_response(uri)
      raw_response = Net::HTTP.get_response(uri)

      if raw_response.is_a?(Net::HTTPSuccess)
        response = valid_response(raw_response)

        if !response.key?(:error)
          if paginate
            response[:data][:pages] = num_pages(response.dig(:data, :total))
            response[:data]
          else
            response[:data][:results].first
          end
        else
          response
        end
      else
        JSON.parse(raw_response.body)
      end
    end

    def valid_response(response)
      JSON.parse(response.body, symbolize_names: true)
    rescue JSON::ParserError
      { error: 'JSON format error' }
    end

    def api_url(args)
      self.params = args[:params]
      self.offset = args[:offset] if args.key?(:offset)
      api_url = "#{BASE_URL}#{endpoint}"

      if params.key?(:id) && !params[:id].nil?
        api_url << "/#{params[:id]}"
        self.paginate = false

        if params.key?(:route) && !params[:route].nil?
          api_url << "/#{params[:route]}"
          self.paginate = true
        end
      end

      api_url
    end

    def proccess_params
      endpoint_params = []

      if paginate
        pagination_params =
          "limit=#{records_per_page.to_i},offset=#{offset.to_i}"

        filters = params.key?(:filters) ? params[:filters] : ''
        filters +=
          !filters.empty? ? pagination_params.prepend(',') : pagination_params

        filters
          .to_s
          .split(',')
          .map { |filter| endpoint_params << filter.split('=') }
      end

      timestamp = '1641187239' # Time.now.to_i.to_s

      endpoint_params.push(
        [:ts, timestamp],
        [:apikey, API_PUBLIC_KEY],
        [:hash, generate_hash(timestamp)]
      )

      endpoint_params
    end

    def generate_hash(timestamp)
      @api_hash = Digest::MD5.new
      @api_hash << timestamp + API_PRIVATE_KEY + API_PUBLIC_KEY
      @api_hash.to_s
    end

    def num_pages(total_records)
      pages = 0

      if !total_records.nil? && total_records.positive?
        compute_pages = total_records / records_per_page
        (compute_pages = compute_pages.floor + 1) unless (compute_pages % 1)
                                                         .zero?
        pages = compute_pages.to_i
      end

      pages
    end
  end
end
