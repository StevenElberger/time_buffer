# frozen_string_literal: true

module TimeBuffer
  class ApplicationHandler
    def initialize(app_data)
      @app_data = app_data
    end

    def insert_application
      TimeBuffer::DatabaseConnector.new.execute(
        "INSERT OR IGNORE INTO applications (bundle_id, app_name) VALUES (?, ?)",
        [app_data.bundle_id, app_data.name]
      )
    end

    private

    attr_reader :app_data
  end
end
