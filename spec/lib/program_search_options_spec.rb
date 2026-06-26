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
          "popular-gem - Many downloads\nsmall-gem - Few downloads"
        )
      end
    end
  end
end
