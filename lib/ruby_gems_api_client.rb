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
    response = get("#{API_URL}/gems/#{gem_name}.json")
    json_response = JSON.parse(response.body)

    GemData.new(json_response['name'], json_response['info'])
  end

  def search(keyword)
    response = get("#{API_URL}/search.json", { query: keyword })
    json_response = JSON.parse(response.body)

    json_response.map do |gem|
      GemData.new(gem['name'], gem['info'], gem['downloads'], gem['licenses'])
    end
  end

  private

  def get(url, params = {})
    @http_client.get(url, params, headers)
  end

  def headers
    { 'Authorization' => ENV['RUBYGEMS_API_KEY'] }
  end
end
