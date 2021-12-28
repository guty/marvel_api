require 'net/http'
require 'digest'
require 'json'

module MarvelApi
  class Base
    BASE_URL = 'https://gateway.marvel.com/v1/public'.freeze
    API_PUBLIC_KEY = '8cd912e48edb1f92f33a672aaca82dda'.freeze
    API_PRIVATE_KEY = '811d7e28093bb09800fd1ddafa7ba191ade52010'.freeze

    attr_writer :endpoint

    def get(filters: '', route: '')
      response = get_response(:filters, :route)

      #data = []
      response ? response[:data][:results] : response

      # if response[:code].to_i == 200
      #   data = response[:data][:results]
      # else
      #   data
      # end
    end

    private

    def get_response(filters, route)
      endpoint_route = numeric?(filters) ? "#{@endpoint}/#{filters}" : @endpoint
      endpoint_route += "/#{route}" if !route.empty?

      uri = URI(BASE_URL + endpoint_route)
      uri_params = !numeric?(filters) ? set_params(filters) : ''

      uri.query = URI.encode_www_form(uri_params)
      raw_response = Net::HTTP.get_response(uri)

      response = valid_response(raw_response) if raw_response.is_a?(
        Net::HTTPSuccess,
      )
    end

    def set_params(filters)
      timestamp = Time.now.to_i.to_s
      params =
        Array(
          {
            ts: timestamp,
            apikey: API_PUBLIC_KEY,
            hash: generate_hash(timestamp),
          },
        )

      if !filters.empty?
        raw_filters = filters.to_s.split(',')
        raw_filters.each { |filter| params << filter.split('=') }
      end

      params
    end

    def generate_hash(timestamp)
      @api_hash = Digest::MD5.new
      @api_hash << timestamp + API_PRIVATE_KEY + API_PUBLIC_KEY
      @api_hash.to_s
    end

    def valid_response(response)
      raw_data = JSON.parse(response.body, symbolize_names: true)
    rescue JSON::ParserError
      nil
    end

    def numeric?(value)
      begin
        Integer(value.to_s) != nil
      rescue StandardError
        false
      end
    end
  end
end
