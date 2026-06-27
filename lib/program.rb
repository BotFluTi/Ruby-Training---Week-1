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
    options = args[2..]

    run_command(command, argument, options)
  end

  def run_command(command, argument, options)
    case command
    when 'show'
      show(argument)
    when 'search'
      search(argument, options)
    else
      ProgramResult.new('Invalid command', 1)
    end
  end

  def show(gem_name)
    return ProgramResult.new('No argument after show', 1) if gem_name.nil?

    gem = @client.gem(gem_name)
    return ProgramResult.new('Gem not found', 1) if gem.nil?

    ProgramResult.new(
      "Name: #{gem.name}\nInfo: #{gem.info}",
      0
    )
  end

  def search(keyword, options = [])
    return ProgramResult.new('No argument after search', 1) if keyword.nil?

    gems = @client.search(keyword)
    gems = apply_search_options(gems, options)

    ProgramResult.new(format_search_output(gems), 0)
  end

  def apply_search_options(gems, options)
    search_options(options).each do |option, value|
      case option
      when '--license'
        gems = filter_by_license(gems, value)
      when '--most-downloads-first'
        gems = sort_by_downloads(gems)
      end
    end

    gems
  end

  def search_options(options)
    options_list = []

    options_list << ['--license', license_value(options)] if options.include?('--license')
    options_list << ['--most-downloads-first', nil] if options.include?('--most-downloads-first')

    options_list
  end

  def license_value(options)
    license_index = options.index('--license')

    options[license_index + 1]
  end

  def filter_by_license(gems, selected_license)
    gems.select { |gem| gem.licenses.include?(selected_license) }
  end

  def sort_by_downloads(gems)
    gems.sort_by(&:downloads).reverse
  end

  def format_search_output(gems)
    gems.map do |gem|
      "#{gem.name} - #{gem.info}"
    end.join("\n")
  end
end
