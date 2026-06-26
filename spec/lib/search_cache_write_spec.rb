# frozen_string_literal: true

require './lib/search_cache'
require './lib/gem_data'
require 'fileutils'
require 'json'

RSpec.describe SearchCache do
  describe '#write' do
    subject(:write) { described_class.new(cache_dir, current_time).write('rails', gems) }

    let(:cache_dir) { 'tmp/test_cache' }
    let(:current_time) { Time.new(2026, 6, 27, 12, 0, 0) }
    let(:cache_data) { JSON.parse(File.read("#{cache_dir}/rails.json")) }

    let(:gems) do
      [
        GemData.new('rails', 'Ruby on Rails is a full-stack web framework.', 100, ['MIT'])
      ]
    end

    after do
      FileUtils.rm_rf(cache_dir)
    end

    it 'creates a cache file for the keyword' do
      write

      expect(File.exist?("#{cache_dir}/rails.json")).to be true
    end

    it 'writes the current time' do
      write

      expect(cache_data['created_at']).to eq(current_time.to_i)
    end

    it 'writes the gem name' do
      write

      expect(cache_data['results'].first['name']).to eq('rails')
    end

    it 'writes the gem info' do
      write

      expect(cache_data['results'].first['info']).to eq(
        'Ruby on Rails is a full-stack web framework.'
      )
    end

    it 'writes the gem downloads' do
      write

      expect(cache_data['results'].first['downloads']).to eq(100)
    end

    it 'writes the gem licenses' do
      write

      expect(cache_data['results'].first['licenses']).to eq(['MIT'])
    end
  end
end
