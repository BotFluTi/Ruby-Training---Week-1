# frozen_string_literal: true

class GemData
  attr_reader :name, :info, :downloads, :licenses

  def initialize(name, info, downloads = 0, licenses = [])
    @name = name
    @info = info
    @downloads = downloads
    @licenses = licenses
  end
end
