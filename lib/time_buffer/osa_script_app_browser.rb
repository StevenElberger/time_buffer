# frozen_string_literal: true

module TimeBuffer
  class OsaScriptAppBrowser < OsaScriptApp
    KNOWN_BROWSERS = %w[com.google.Chrome]

    def self.inherited
      KNOWN_BROWSERS.each do |bundle_id|
        OsaScriptAppBuilder.register(app_bundle_id: bundle_id, app_class: self.class)
      end
    end

    def initialize(app_bundle_id)
      @bundle_id = app_bundle_id
    end

    def current_tab
      `osascript -e 'tell application "Google Chrome" to get title of active tab of front window'`.strip
    end
  end
end
