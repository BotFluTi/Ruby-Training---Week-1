# frozen_string_literal: true

require './lib/ruby_gems_api_client'

RSpec.describe 'RubyGemsApiClient authentication' do
  let(:http_client) { double('http_client') }
  let(:response) { double('response', body: response_body) }

  before do
    allow(ENV).to receive(:[]).with('RUBYGEMS_API_KEY').and_return('secret-key')
    allow(http_client).to receive(:get).and_return(response)
  end

  describe '#gem' do
    let(:response_body) { File.read('./spec/fixtures/rails_gem.json') }

    it 'sends the API key from ENV in the request headers' do
      RubyGemsApiClient.new(http_client).gem('rails')

      expect(http_client).to have_received(:get).with(
        "#{RubyGemsApiClient::API_URL}/gems/rails.json",
        {},
        { 'Authorization' => 'secret-key' }
      )
    end
  end

  describe '#search' do
    let(:response_body) { File.read('./spec/fixtures/rails_search.json') }

    it 'sends the API key from ENV in the request headers' do
      RubyGemsApiClient.new(http_client).search('rails')

      expect(http_client).to have_received(:get).with(
        "#{RubyGemsApiClient::API_URL}/search.json",
        { query: 'rails' },
        { 'Authorization' => 'secret-key' }
      )
    end
  end
end