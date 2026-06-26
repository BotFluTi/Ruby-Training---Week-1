# frozen_string_literal: true

class GemData
  attr_reader :name, :info, :downloads

  def initialize(name, info, downloads = 0)
    @name = name
    @info = info
    @downloads = downloads
  end
end
