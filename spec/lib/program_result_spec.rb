require './lib/program_result'

RSpec.describe 'ProgramResult' do
  describe '#initialize' do
    subject(:program_result) { ProgramResult.new('Name: rails', 0) }

    it 'returns output' do
      expect(program_result.output).to eq('Name: rails')
    end

    it 'returns exit code' do
      expect(program_result.exit_code).to eq(0)
    end
  end
end