# frozen_string_literal: true

module TimeBuffer
  class OsaScriptApp
    attr_reader :bundle_id

    def initialize(app_bundle_id)
      @bundle_id = app_bundle_id
    end

    def name
      @name ||= `osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true'`.strip
    end
  end
end
