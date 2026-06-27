# frozen_string_literal: true

require './lib/ruby_gems_api_client'
require 'faraday'

RSpec.describe RubyGemsApiClient do
  let(:http_client) { class_double(Faraday) }
  let(:response) { MockResponse.new(response_body) }

  before do
    allow(http_client).to receive(:get).and_return(response)
  end

  describe '#gem' do
    subject(:gem) { described_class.new(http_client).gem('rails') }

    let(:response_body) { File.read('spec/fixtures/rails_gem.json') }

    it 'returns gem name about the provided gem name' do
      expect(gem.name).to eq('rails')
    end

    it 'returns gem info about the provided gem name' do
      expect(gem.info).to eq('Ruby on Rails is a full-stack web framework.')
    end

    it 'sends the API key from ENV in the request headers' do
      allow(ENV).to receive(:[]).with('RUBYGEMS_API_KEY').and_return('secret-key')

      gem

      expect_authenticated_get('/gems/rails.json', {})
    end
  end

  describe '#search' do
    subject(:search) { described_class.new(http_client).search('rails') }

    let(:response_body) { File.read('spec/fixtures/rails_search.json') }

    it 'returns search results' do
      expect(search.length).to eq(2)
    end

    it 'returns first gem name about the provided keyword' do
      expect(search.first.name).to eq('rails')
    end

    it 'returns first gem info about the provided keyword' do
      expect(search.first.info).to eq('Ruby on Rails is a full-stack web framework.')
    end

    it 'returns first gem downloads' do
      expect(search.first.downloads).to eq(100)
    end

    it 'returns first gem licenses' do
      expect(search.first.licenses).to eq(['MIT'])
    end

    it 'sends the API key from ENV in the request headers' do
      allow(ENV).to receive(:[]).with('RUBYGEMS_API_KEY').and_return('secret-key')

      search

      expect_authenticated_get('/search.json', { query: 'rails' })
    end
  end

  def expect_authenticated_get(path, params)
    expect(http_client).to have_received(:get).with(
      "#{RubyGemsApiClient::API_URL}#{path}",
      params,
      { 'Authorization' => 'secret-key' }
    )
  end
end
