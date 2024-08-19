# frozen_string_literal: true

require "json"

module TimeBuffer
  class SessionHandler
    def initialize(start_time:, end_time:)
      @start_time = start_time
      @end_time = end_time
    end

    def insert_time_session(app_data)
      application_id = TimeBuffer::DatabaseConnector.new.execute(
        "SELECT id FROM applications WHERE bundle_id = ?",
        [app_data.bundle_id]
      ).first&.first

      puts "application ID: #{application_id}"

      TimeBuffer::DatabaseConnector.new.execute(
        "INSERT INTO time_sessions (application_id, start_time, end_time, metadata) VALUES (?, ?, ?, ?);",
        [application_id, start_time.strftime("%Y-%m-%d %H:%M:%S"), end_time.strftime("%Y-%m-%d %H:%M:%S"), app_data.metadata.to_json]
      )
    end

    private

    attr_reader :start_time, :end_time
  end
end
