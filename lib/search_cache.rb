# frozen_string_literal: true

require './lib/gem_data'
require 'fileutils'
require 'json'

class SearchCache
  CACHE_TIME_EXP = 2 * 24 * 60 * 60

  def initialize(cache_dir, current_time = Time.now)
    @cache_dir = cache_dir
    @current_time = current_time
  end

  # rubocop:disable Metrics/MethodLength
  def read(keyword)
    return nil unless File.exist?(cache_file_path(keyword))

    cache_data = JSON.parse(File.read(cache_file_path(keyword)))

    return nil if expired?(cache_data['created_at'])

    cache_data['results'].map do |gem_data|
      GemData.new(
        gem_data['name'],
        gem_data['info'],
        gem_data['downloads'],
        gem_data['licenses']
      )
    end
  end

  def write(keyword, gems)
    FileUtils.mkdir_p(@cache_dir)

    cache_data = {
      created_at: @current_time.to_i,
      results: gems.map do |gem_data|
        {
          name: gem_data.name,
          info: gem_data.info,
          downloads: gem_data.downloads,
          licenses: gem_data.licenses
        }
      end
    }

    File.write(cache_file_path(keyword), cache_data.to_json)
  end

  # rubocop:enable Metrics/MethodLength
  private

  def cache_file_path(keyword)
    "#{@cache_dir}/#{keyword}.json"
  end

  def expired?(created_at)
    @current_time.to_i - created_at > CACHE_TIME_EXP
  end
end
