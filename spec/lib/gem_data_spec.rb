# frozen_string_literal: true

require './lib/gem_data'

RSpec.describe 'GemData' do
  describe '#initialize' do
    subject(:gem_data) { GemData.new('rails', 'Web framework', 100, ['MIT']) }

    it 'returns gem name' do
      expect(gem_data.name).to eq('rails')
    end

    it 'returns gem info' do
      expect(gem_data.info).to eq('Web framework')
    end

    it 'returns downloads' do
      expect(gem_data.downloads).to eq(100)
    end

    it 'returns licenses' do
      expect(gem_data.licenses).to eq(['MIT'])
    end

    it 'returns empty licenses when licenses are nil' do
      gem_data = GemData.new('rails', 'Web framework', 100, nil)

      expect(gem_data.licenses).to eq([])
    end
  end
end
