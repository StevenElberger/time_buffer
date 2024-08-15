# frozen_string_literal: true

require_relative "time_buffer/database_connector"
require_relative "time_buffer/osa_script"
require_relative "time_buffer/osa_script_app"
require_relative "time_buffer/osa_script_app_browser"
require_relative "time_buffer/osa_script_app_builder"
require_relative "time_buffer/session"
require_relative "time_buffer/version"
require "sqlite3"
module TimeBuffer
  class Tracker
    class << self
      Database = DatabaseConnector.new

      def start
        previous_app = nil
        previous_metadata = nil
        last_interaction_at = Time.now

        loop do
          app_data = OsaScript.app_data
          app_name = app_data.name

          if app_name != previous_app
            puts "Active application changed to: #{app_name}"
            now = Time.now
            insert_application(app_data)
            session_data = Session.new(start_time: last_interaction_at, end_time: now)
            last_interaction_at = now
            insert_time_session(session_data, app_data)
            previous_app = app_name
          end

          metadata = app_data.metadata
          puts "Current metadata: #{metadata}"
          if metadata
            if metadata != previous_metadata && !previous_metadata&.empty?
              puts "Active tab changed to #{metadata}"
              now = Time.now
              session_data = Session.new(start_time: last_interaction_at, end_time: now)
              last_interaction_at = now
              insert_time_session(session_data, app_data)
              previous_metadata = metadata
            end
          end

          sleep 1
        end
      end

      def insert_application(app_data)
        Database.execute("INSERT OR IGNORE INTO applications (bundle_id, app_name) VALUES (?, ?)", [app_data.bundle_id, app_data.name])
      end

      def insert_time_session(session_data, app_data)
        Database.execute("INSERT INTO time_sessions (application_id, start_time, end_time, metadata) SELECT id, ?, ? FROM applications WHERE bundle_id = ?;", [session_data.start_time, session_data.end_time, app_data.bundle_id, app_data.metadata])
      end
    end
  end
end
