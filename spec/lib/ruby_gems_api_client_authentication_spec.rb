# frozen_string_literal: true

require './lib/ruby_gems_api_client'
require 'faraday'

RSpec.describe RubyGemsApiClient do
  let(:http_client) { class_double(Faraday) }
  let(:response) { MockResponse.new(response_body) }

  before do
    allow(ENV).to receive(:[]).with('RUBYGEMS_API_KEY').and_return('secret-key')
    allow(http_client).to receive(:get).and_return(response)
  end

  def expect_authenticated_get(path, params)
    expect(http_client).to have_received(:get).with(
      "#{RubyGemsApiClient::API_URL}#{path}",
      params,
      { 'Authorization' => 'secret-key' }
    )
  end

  describe '#gem' do
    let(:response_body) { File.read('./spec/fixtures/rails_gem.json') }

    it 'sends the API key from ENV in the request headers' do
      described_class.new(http_client).gem('rails')

      expect_authenticated_get('/gems/rails.json', {})
    end
  end

  describe '#search' do
    let(:response_body) { File.read('./spec/fixtures/rails_search.json') }

    it 'sends the API key from ENV in the request headers' do
      described_class.new(http_client).search('rails')

      expect_authenticated_get('/search.json', { query: 'rails' })
    end
  end
end
