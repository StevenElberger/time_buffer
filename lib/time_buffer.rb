# frozen_string_literal: true

require_relative "time_buffer/application_handler"
require_relative "time_buffer/database_connector"
require_relative "time_buffer/osa_script"
require_relative "time_buffer/osa_script_app"
require_relative "time_buffer/osa_script_app_browser"
require_relative "time_buffer/osa_script_app_builder"
require_relative "time_buffer/session_handler"
require_relative "time_buffer/state_detector"
require_relative "time_buffer/version"
require "sqlite3"
module TimeBuffer
  class Tracker
    def initialize
      @state_detector = StateDetector.new
    end

    def start
      loop do
        now = Time.now

        if state_detector.app_changed?
          handle_app_change(state_detector.current_app_data, now)
        elsif state_detector.metadata_changed?
          handle_metadata_change(state_detector.current_app_data, now)
        end

        sleep 1
      end
    end

    private

    attr_reader :state_detector

    def handle_app_change(app_data, now)
      ApplicationHandler.new(app_data).insert_application
      SessionHandler.new(start_time: state_detector.last_interaction_at, end_time: now).insert_time_session(app_data)
      state_detector.update_last_interaction_time(now)
    end

    def handle_metadata_change(app_data, now)
      SessionHandler.new(start_time: state_detector.last_interaction_at, end_time: now).insert_time_session(app_data)
      state_detector.update_last_interaction_time(now)
    end
  end
end
