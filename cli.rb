# frozen_string_literal: true

require 'bundler/setup'
require 'faraday'
require './lib/program'
require './lib/ruby_gems_api_client'

client = RubyGemsApiClient.new(Faraday)
result = Program.new(client).execute(ARGV)

puts result.output
exit result.exit_code
