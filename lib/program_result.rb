class ProgramResult
  attr_reader :output, :exit_code

  def initialize(output, exit_code)
    @output = output
    @exit_code = exit_code
  end
end