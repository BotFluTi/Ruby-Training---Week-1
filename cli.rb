require 'bundler/setup'
require_relative 'lib/program'
require_relative 'lib/ruby_gems_api_client'

result = Program.new(RubyGemsApiClient.new).execute(ARGV)

puts result.output
exit result.exit_code
