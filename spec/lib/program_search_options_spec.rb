# frozen_string_literal: true

require './lib/program'
require './lib/gem_data'
require './lib/ruby_gems_api_client'

RSpec.describe Program do
  describe '#execute' do
    subject(:execute) { described_class.new(client).execute(args) }

    let(:client) { instance_double(RubyGemsApiClient) }

    context 'when search has --most-downloads-first option' do
      let(:args) { %w[search rails --most-downloads-first] }

      before do
        allow(client).to receive(:search) do
          [
            GemData.new('small-gem', 'Few downloads', 10),
            GemData.new('popular-gem', 'Many downloads', 100)
          ]
        end
      end

      it 'returns gems ordered by downloads descending' do
        expect(execute.output).to eq(
          "popular-gem - Many downloads - Downloads: 100\n" \
          'small-gem - Few downloads - Downloads: 10'
        )
      end
    end

    context 'when search has --license option' do
      let(:args) { %w[search email --license MIT] }

      before do
        allow(client).to receive(:search) do
          [
            GemData.new('mit-gem', 'MIT licensed gem', 10, ['MIT']),
            GemData.new('apache-gem', 'Apache licensed gem', 20, ['Apache-2.0'])
          ]
        end
      end

      it 'returns only gems with the selected license' do
        expect(execute.output).to eq('mit-gem - MIT licensed gem')
      end
    end

    context 'when search has license and most downloads first options' do
      let(:args) { %w[search email --license MIT --most-downloads-first] }

      before do
        allow(client).to receive(:search) do
          [
            GemData.new('less-popular-mit-gem', 'MIT gem', 10, ['MIT']),
            GemData.new('apache-gem', 'Apache gem', 100, ['Apache-2.0']),
            GemData.new('more-popular-mit-gem', 'MIT gem', 50, ['MIT'])
          ]
        end
      end

      it 'filters by license and orders by downloads descending' do
        expect(execute.output).to eq(
          "more-popular-mit-gem - MIT gem - Downloads: 50\n" \
          'less-popular-mit-gem - MIT gem - Downloads: 10'
        )
      end
    end
  end
end
