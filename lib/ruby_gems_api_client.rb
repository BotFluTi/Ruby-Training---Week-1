# frozen_string_literal: true

require 'faraday'
require 'json'
require './lib/gem_data'

class RubyGemsApiClient
  API_URL = 'https://rubygems.org/api/v1'

  def initialize(http_client)
    @http_client = http_client
  end

  def gem(gem_name)
    response = @http_client.get("#{API_URL}/gems/#{gem_name}.json")
    json_response = JSON.parse(response.body)

    GemData.new(json_response['name'], json_response['info'])
  end

  def search(keyword)
    response = @http_client.get("#{API_URL}/search.json", { query: keyword })
    json_response = JSON.parse(response.body)

    json_response.map do |gem|
      GemData.new(gem['name'], gem['info'])
    end
  end
end
