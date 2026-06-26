# frozen_string_literal: true

require './lib/search_cache'
require 'fileutils'
require 'json'

RSpec.describe SearchCache do
  describe '#read' do
    subject(:read) { described_class.new(cache_dir, current_time).read('rails') }

    let(:cache_dir) { 'tmp/test_cache' }
    let(:current_time) { Time.new(2026, 6, 27, 12, 0, 0) }

    before do
      FileUtils.mkdir_p(cache_dir)

      File.write(
        "#{cache_dir}/rails.json",
        {
          created_at: Time.new(2026, 6, 26, 12, 0, 0).to_i,
          results: [
            {
              name: 'rails',
              info: 'Ruby on Rails is a full-stack web framework.',
              downloads: 100,
              licenses: ['MIT']
            }
          ]
        }.to_json
      )
    end

    after do
      FileUtils.rm_rf(cache_dir)
    end

    it 'returns cached gems when cache is not expired' do
      expect(read.first.name).to eq('rails')
    end
  end
end