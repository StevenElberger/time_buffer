# frozen_string_literal: true

require_relative "osa_script_app_builder"

module TimeBuffer
  class OsaScriptAppBrowser < OsaScriptApp
    KNOWN_BROWSERS = %w[com.google.Chrome]

    def self.register_known_browsers
      KNOWN_BROWSERS.each do |bundle_id|
        OsaScriptAppBuilder.register(app_bundle_id: bundle_id, app_class: self)
      end
    end

    register_known_browsers

    def initialize(app_bundle_id)
      @bundle_id = app_bundle_id
    end

    def metadata
      {
        tab_title: tab_title
      }
    end

    def tab_title
      `osascript -e 'tell application "Google Chrome" to get title of active tab of front window'`.strip
    end
  end
end
