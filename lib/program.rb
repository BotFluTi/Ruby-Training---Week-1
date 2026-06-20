# frozen_string_literal: true

require_relative 'program_result'

class Program
  def initialize(client)
    @client = client
  end

  def execute(args)
    command = args[0]
    argument = args[1]

    case command
    when 'show'
      show(argument)
    when 'search'
      search(argument)
    end
  end

  private

  def show(gem_name)
    gem = @client.gem(gem_name)

    ProgramResult.new(
      "Name: #{gem.name}\nInfo: #{gem.info}",
      0
    )
  end

  def search(keyword)
    gems = @client.search(keyword)

    output = gems.map do |gem|
      "#{gem.name} - #{gem.info}"
    end.join("\n")

    ProgramResult.new(output, 0)
  end
end
