# frozen_string_literal: true

require './lib/search_cache'
require 'fileutils'
require 'json'

RSpec.describe SearchCache do
  describe '#read' do
    subject(:read) { described_class.new(cache_dir, current_time).read(keyword) }

    let(:cache_dir) { 'tmp/test_cache' }
    let(:current_time) { Time.new(2026, 6, 27, 12, 0, 0) }

    after do
      FileUtils.rm_rf(cache_dir)
    end

    context 'when cache file exists and is not expired' do
      let(:keyword) { 'rails' }

      before do
        write_cache_file(
          'rails',
          created_at: Time.new(2026, 6, 26, 12, 0, 0).to_i,
          results: [cached_gem_data]
        )
      end

      it 'returns cached gem name' do
        expect(read.first.name).to eq('rails')
      end

      it 'returns cached gem info' do
        expect(read.first.info).to eq('Ruby on Rails is a full-stack web framework.')
      end

      it 'returns cached gem downloads' do
        expect(read.first.downloads).to eq(100)
      end

      it 'returns cached gem licenses' do
        expect(read.first.licenses).to eq(['MIT'])
      end
    end

    context 'when cache file does not exist' do
      let(:keyword) { 'missing' }

      it 'returns nil' do
        expect(read).to be_nil
      end
    end

    context 'when cache file is expired' do
      let(:keyword) { 'rails' }

      before do
        write_cache_file(
          'rails',
          created_at: Time.new(2026, 6, 24, 11, 59, 59).to_i,
          results: [cached_gem_data]
        )
      end

      it 'returns nil' do
        expect(read).to be_nil
      end
    end

    def cached_gem_data
      {
        name: 'rails',
        info: 'Ruby on Rails is a full-stack web framework.',
        downloads: 100,
        licenses: ['MIT']
      }
    end

    def write_cache_file(keyword, cache_data)
      FileUtils.mkdir_p(cache_dir)

      File.write(
        "#{cache_dir}/#{keyword}.json",
        cache_data.to_json
      )
    end
  end
end
