require 'faraday'
require 'json'

class Commands
  API_URL = 'https://rubygems.org/api/v1'

  def self.run
    command = ARGV[0]
    argument = ARGV[1]

    case command
    when 'search'
      search(argument)
    when 'show'
      show(argument)
    else
      puts 'Usage:'
      puts '  ruby cli.rb search <keyword>'
      puts '  ruby cli.rb show <gem_name>'
      exit 1
    end
  end

  def self.search(keyword)
    if keyword.nil? || keyword.empty?
      puts 'Please provide a search keyword.'
      exit 1
    end

    response = Faraday.get("#{API_URL}/search.json", { query: keyword })

    unless response.success?
      puts 'Could not connect to RubyGems.'
      exit 1
    end

    gems = JSON.parse(response.body)

    matching_by_name = gems.select do |gem|
      gem['name'].downcase.include?(keyword.downcase)
    end

    matching_by_info = gems.select do |gem|
      gem['info'].to_s.downcase.include?(keyword.downcase) &&
        !gem['name'].downcase.include?(keyword.downcase)
    end

    results = matching_by_name + matching_by_info

    if results.empty?
      puts "No gems found for '#{keyword}'."
      exit 0
    end

    results.each do |gem|
      puts "#{gem['name']} - #{gem['info']}"
    end

    exit 0
  end

  def self.show(gem_name)
    if gem_name.nil? || gem_name.empty?
      puts 'Please provide a gem name.'
      exit 1
    end

    response = Faraday.get("#{API_URL}/gems/#{gem_name}.json")

    unless response.success?
      puts "Gem '#{gem_name}' was not found."
      exit 1
    end

    gem = JSON.parse(response.body)

    puts "Name: #{gem['name']}"
    puts "Version: #{gem['version']}"
    puts "Authors: #{gem['authors']}"
    puts "Info: #{gem['info']}"
    puts "Downloads: #{gem['downloads']}"
    puts "Project URI: #{gem['project_uri']}"
    puts "Homepage URI: #{gem['homepage_uri']}"

    exit 0
  end
end