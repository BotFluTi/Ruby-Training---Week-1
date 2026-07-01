# frozen_string_literal: true

require './lib/program_result'
require './lib/search_cache'
require 'faraday'
require 'optparse'

class Program
  def initialize(client, cache = SearchCache.new('tmp'))
    @client = client
    @cache = cache
  end

  def execute(args)
    execute_command(args)
  rescue Faraday::TimeoutError
    ProgramResult.new('Request timed out', 1)
  rescue OptionParser::ParseError => e
    ProgramResult.new(e.message, 1)
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

    search_options = parse_search_options(options)
    gems = search_with_cache(keyword)
    gems = apply_search_options(gems, search_options)

    ProgramResult.new(format_search_output(gems, search_options), 0)
  end

  def search_with_cache(keyword)
    cached_gems = @cache.read(keyword)
    return cached_gems unless cached_gems.nil?

    gems = @client.search(keyword)
    @cache.write(keyword, gems)
    gems
  end

  def parse_search_options(options)
    search_options = default_search_options

    search_options_parser(search_options).parse!(options)

    search_options
  end

  def default_search_options
    {
      license: nil,
      most_downloads_first: false
    }
  end

  def search_options_parser(search_options)
    OptionParser.new do |parser|
      parser.on('--license LICENSE') do |license|
        search_options[:license] = license
      end

      parser.on('--most-downloads-first') do
        search_options[:most_downloads_first] = true
      end
    end
  end

  def apply_search_options(gems, search_options)
    gems = filter_by_license(gems, search_options[:license]) if search_options[:license]
    gems = sort_by_downloads(gems) if search_options[:most_downloads_first]

    gems
  end

  def filter_by_license(gems, selected_license)
    gems.select { |gem| gem.licenses.include?(selected_license) }
  end

  def sort_by_downloads(gems)
    gems.sort_by(&:downloads).reverse
  end

  def format_search_output(gems, search_options)
    gems.map do |gem|
      format_gem(gem, search_options)
    end.join("\n")
  end

  def format_gem(gem, search_options)
    output = "#{gem.name} - #{gem.info}"
    return output unless search_options[:most_downloads_first]

    "#{output} - Downloads: #{gem.downloads}"
  end
end
