# frozen_string_literal: true

require './lib/search_cache'
require './lib/gem_data'
require 'fileutils'
require 'json'

RSpec.describe SearchCache do
  let(:cache) do
    {
      dir: 'cache',
      keyword: 'rails',
      file_path: 'cache/rails.json',
      file_content: File.read('spec/fixtures/rails_cache.json')
    }
  end

  let(:time) do
    {
      created_at: 100_000,
      one_day: 24 * 60 * 60
    }
  end

  describe '#read' do
    subject(:read) { described_class.new(cache[:dir], current_time).read(cache[:keyword]) }

    context 'when cache file exists and is not expired' do
      let(:current_time) { Time.at(time[:created_at] + time[:one_day]) }

      before do
        allow(File).to receive(:exist?).with(cache[:file_path]).and_return(true)
        allow(File).to receive(:read).with(cache[:file_path]).and_return(cache[:file_content])
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
      let(:current_time) { Time.at(time[:created_at] + time[:one_day]) }

      before do
        allow(File).to receive(:exist?).with(cache[:file_path]).and_return(false)
      end

      it 'returns nil' do
        expect(read).to be_nil
      end
    end

    context 'when cache file is expired' do
      let(:current_time) { Time.at(time[:created_at] + (3 * time[:one_day])) }

      before do
        allow(File).to receive(:exist?).with(cache[:file_path]).and_return(true)
        allow(File).to receive(:read).with(cache[:file_path]).and_return(cache[:file_content])
      end

      it 'returns nil' do
        expect(read).to be_nil
      end
    end
  end

  describe '#write' do
    subject(:write) { described_class.new(cache[:dir], current_time).write(cache[:keyword], gems) }

    let(:current_time) { Time.at(time[:created_at]) }

    let(:cache_data_json) do
      {
        created_at: current_time.to_i,
        results: [
          {
            name: 'rails',
            info: 'Ruby on Rails is a full-stack web framework.',
            downloads: 100,
            licenses: ['MIT']
          }
        ]
      }.to_json
    end

    let(:gems) do
      [
        GemData.new('rails', 'Ruby on Rails is a full-stack web framework.', 100, ['MIT'])
      ]
    end

    before do
      allow(FileUtils).to receive(:mkdir_p)
      allow(File).to receive(:write)
    end

    it 'creates the cache directory' do
      write

      expect(FileUtils).to have_received(:mkdir_p).with(cache[:dir])
    end

    it 'writes cache data to the file' do
      write

      expect(File).to have_received(:write).with(
        cache[:file_path],
        cache_data_json
      )
    end
  end
end
