require './lib/program'
require './lib/gem_data'
require './lib/ruby_gems_api_client'

RSpec.describe 'Program' do
  describe '#execute' do
    subject(:execute) { Program.new(client).execute(args) }

    let(:client) { instance_double(RubyGemsApiClient) }

    context 'when command is show' do
      let(:args) { %w[show rails] }

      before do
        allow(client).to receive(:gem) do
          GemData.new('rails', 'Web framework')
        end
      end

      it 'returns 0 exit code' do
        expect(execute.exit_code).to eq(0)
      end

      it 'returns output when command is show' do
        expect(execute.output).to eq("Name: rails\nInfo: Web framework")
      end
    end

    context 'when command is search' do
      let(:args) { %w[search rails] }

      before do
        allow(client).to receive(:search) do
          [
            GemData.new('rails', 'Web framework'),
            GemData.new('rails-html-sanitizer', 'HTML sanitizer')
          ]
        end
      end

      it 'returns 0 exit code' do
        expect(execute.exit_code).to eq(0)
      end

      it 'returns output when command is search' do
        expect(execute.output).to eq(
          "rails - Web framework\nrails-html-sanitizer - HTML sanitizer"
        )
      end
    end
  end
end