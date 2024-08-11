# frozen_string_literal: true

require_relative "time_buffer/version"
require "sqlite3"

class OsaScript
  class << self
    def app_data
      current_app_bundle_id = `osascript -e 'id of application (path to frontmost application as text)'`.strip
      app_name = case current_app_bundle_id
      when "com.microsoft.VSCode"
        "Visual Studio Code"
      when "com.google.Chrome"
        "Google Chrome"
      else
        `osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true'`.strip
      end
      {bundle_id: current_app_bundle_id, name: app_name}
    end
  end
end

module TimeBuffer
  class Tracker
    # Define start
    class << self
      def db
        @db ||= SQLite3::Database.new "usage_data.db"
      end

      def initialize
        # Create or open an SQLite database file
        @db = SQLite3::Database.new "usage_data.db"

        # Execute SQL statements to create the tables

        # 1. Applications Table
        @db.execute <<-SQL
          CREATE TABLE IF NOT EXISTS applications (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            bundle_id TEXT UNIQUE NOT NULL,
            app_name TEXT NOT NULL
          );
        SQL

        # 2. Time Sessions Table
        @db.execute <<-SQL
          CREATE TABLE IF NOT EXISTS time_sessions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            application_id INTEGER NOT NULL,
            start_time DATETIME NOT NULL,
            end_time DATETIME,
            FOREIGN KEY (application_id) REFERENCES applications(id)
          );
        SQL

        # 3. Daily Summaries Table
        @db.execute <<-SQL
          CREATE TABLE IF NOT EXISTS daily_summaries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            application_id INTEGER NOT NULL,
            date DATE NOT NULL,
            total_duration INTEGER NOT NULL,
            FOREIGN KEY (application_id) REFERENCES applications(id),
            UNIQUE(application_id, date)
          );
        SQL

        # Close the database connection
        @db.close

        puts "Database initialized successfully."
      end

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
        db.execute("INSERT OR IGNORE INTO applications (bundle_id, app_name) VALUES (?, ?)", [app_data[:bundle_id], app_data[:name]])
      end

      def insert_time_session(session_data, app_data)
        db.execute("INSERT INTO time_sessions (application_id, start_time, end_time) SELECT id, ?, ? FROM applications WHERE bundle_id = ?;", [session_data[:start_time], session_data[:end_time], app_data[:bundle_id]])
      end
    end
  end
end
