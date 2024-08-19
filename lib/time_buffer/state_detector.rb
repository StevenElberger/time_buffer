# frozen_string_literal: true

module TimeBuffer
  class StateDetector
    attr_reader :current_app_data, :last_interaction_at, :previous_app, :previous_metadata

    def initialize
      @previous_app = nil
      @previous_metadata = {}
      @last_interaction_at = Time.now
      @current_app_data = nil
    end

    def app_changed?
      @current_app_data = OsaScript.app_data
      @current_app_data.name != @previous_app
    end

    def metadata_changed?
      metadata = current_app_data.metadata
      metadata && metadata != previous_metadata && current_app_data.name == previous_app
    end

    def update_last_interaction_time(now)
      @last_interaction_at = now
      update_state
    end

    private

    def update_state
      @previous_app = current_app_data.name
      @previous_metadata = current_app_data.metadata
    end
  end
end
