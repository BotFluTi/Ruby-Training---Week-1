# frozen_string_literal: true

require './lib/gem_data'

RSpec.describe 'GemData' do
  describe '#initialize' do
    subject(:gem_data) { GemData.new('rails', 'Web framework', 123) }

    it 'returns gem name' do
      expect(gem_data.name).to eq('rails')
    end

    it 'returns gem info' do
      expect(gem_data.info).to eq('Web framework')
    end

    it 'returns downloads' do
      expect(gem_data.downloads).to eq(123)
    end
  end
end
