# frozen_string_literal: true

class Session
  def initialize(start_time:, end_time:)
    @start_time = start_time.strftime("%Y-%m-%d %H:%M:%S")
    @end_time = end_time.strftime("%Y-%m-%d %H:%M:%S")
  end

  attr_reader :start_time, :end_time
end
