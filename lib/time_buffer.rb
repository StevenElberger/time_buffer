# frozen_string_literal: true

require_relative "time_buffer/version"
require_relative "database_connector"
require_relative "osa_script"
require "sqlite3"

module TimeBuffer
  class Tracker
    class << self
      Database = DatabaseConnector.new

      def start
        previous_app = nil
        previous_tab = nil
        last_interaction_at = Time.now
        data = {
          "Visual Studio Code" => {
            sessions: 0,
            total_duration: 0
          },
          "Google Chrome" => {
            sessions: 0,
            total_duration: 0
          }
        }
        loop do
          app_data = OsaScript.app_data
          app_name = app_data[:name]
          data[app_name] ||= {sessions: 0, total_duration: 0}
          if app_name == "Google Chrome"
            current_tab = `osascript -e 'tell application "Google Chrome" to get title of active tab of front window'`.strip
            if current_tab != previous_tab
              puts "Active Chrome tab changed to: #{current_tab}"
              previous_tab = current_tab
            end
          end

          if app_name != previous_app
            puts "Active application changed to: #{app_name}"
            now = Time.now
            curr_duration = (now - last_interaction_at).to_i
            data[app_name][:sessions] += 1
            data[app_name][:total_duration] += curr_duration
            last_interaction_at = Time.now
            insert_application(app_data)
            session_data = {start_time: last_interaction_at.strftime("%Y-%m-%d %H:%M:%S"), end_time: now.strftime("%Y-%m-%d %H:%M:%S")}
            insert_time_session(session_data, app_data)
            previous_app = app_name
            puts "Data: #{data}"
          end

          sleep 1
        end
      end

      def insert_application(app_data)
        Database.execute("INSERT OR IGNORE INTO applications (bundle_id, app_name) VALUES (?, ?)", [app_data[:bundle_id], app_data[:name]])
      end

      def insert_time_session(session_data, app_data)
        Database.execute("INSERT INTO time_sessions (application_id, start_time, end_time) SELECT id, ?, ? FROM applications WHERE bundle_id = ?;", [session_data[:start_time], session_data[:end_time], app_data[:bundle_id]])
      end
    end
  end
end
