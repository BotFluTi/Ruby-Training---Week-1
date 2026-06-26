# frozen_string_literal: true

require './lib/ruby_gems_api_client'
require 'faraday'

RSpec.describe 'RubyGemsApiClient' do
  describe '#gem' do
    subject(:gem) { RubyGemsApiClient.new(http_client).gem('rails') }

    let(:http_client) { class_double(Faraday) }
    let(:mock_response) { MockResponse.new(File.read('spec/fixtures/rails_gem.json')) }

    before do
      allow(http_client).to receive(:get) { mock_response }
    end

    it 'returns gem name about the provided gem name' do
      expect(gem.name).to eq('rails')
    end

    it 'returns gem info about the provided gem name' do
      expect(gem.info).to eq('Ruby on Rails is a full-stack web framework.')
    end
  end

  describe '#search' do
    subject(:search) { RubyGemsApiClient.new(http_client).search('rails') }

    let(:http_client) { class_double(Faraday) }
    let(:mock_response) { MockResponse.new(File.read('spec/fixtures/rails_search.json')) }

    before do
      allow(http_client).to receive(:get) { mock_response }
    end

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
  end
end
