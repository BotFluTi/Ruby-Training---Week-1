# frozen_string_literal: true

class GemData
  attr_reader :name, :info

  def initialize(name, info)
    @name = name
    @info = info
  end
end
