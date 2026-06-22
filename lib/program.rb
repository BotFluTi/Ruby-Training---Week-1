# frozen_string_literal: true

require './lib/program_result'
require 'faraday'

class Program
  def initialize(client)
    @client = client
  end

  def execute(args)
    execute_command(args)
  rescue Faraday::TimeoutError
    ProgramResult.new('Request timed out', 1)
  end

  private

  def execute_command(args)
    command = args[0]
    argument = args[1]

    case command
    when 'show'
      show(argument)
    when 'search'
      search(argument)
    else
      ProgramResult.new('Invalid command', 1)
    end
  end

  def show(gem_name)
    return ProgramResult.new('No argument after show', 1) if gem_name.nil?

    gem = @client.gem(gem_name)

    ProgramResult.new(
      "Name: #{gem.name}\nInfo: #{gem.info}",
      0
    )
  end

  def search(keyword)
    return ProgramResult.new('No argument after search', 1) if keyword.nil?

    gems = @client.search(keyword)

    output = gems.map do |gem|
      "#{gem.name} - #{gem.info}"
    end.join("\n")

    ProgramResult.new(output, 0)
  end
end
