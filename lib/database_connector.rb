# frozen_string_literal: true

module TimeBuffer
  class DatabaseConnector
    class << self
      FILE_LOCATION = "usage_data.db"

      def start
        db = SQLite3::Database.new FILE_LOCATION
        return db if File.exist?(FILE_LOCATION)

        # 1. Applications Table
        db.execute <<-SQL
          CREATE TABLE IF NOT EXISTS applications (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            bundle_id TEXT UNIQUE NOT NULL,
            app_name TEXT NOT NULL
          );
        SQL

        # 2. Time Sessions Table
        db.execute <<-SQL
          CREATE TABLE IF NOT EXISTS time_sessions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            application_id INTEGER NOT NULL,
            start_time DATETIME NOT NULL,
            end_time DATETIME,
            FOREIGN KEY (application_id) REFERENCES applications(id)
          );
        SQL

        # 3. Daily Summaries Table
        db.execute <<-SQL
          CREATE TABLE IF NOT EXISTS daily_summaries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            application_id INTEGER NOT NULL,
            date DATE NOT NULL,
            total_duration INTEGER NOT NULL,
            FOREIGN KEY (application_id) REFERENCES applications(id),
            UNIQUE(application_id, date)
          );
        SQL

        puts "Database initialized successfully."

        db
      end
    end
  end
end
