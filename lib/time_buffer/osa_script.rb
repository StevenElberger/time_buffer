# frozen_string_literal: true

module TimeBuffer
  class OsaScript
    class << self
      def app_data
        current_app_bundle_id = `osascript -e 'id of application (path to frontmost application as text)'`.strip
        app = OsaScriptAppBuilder.build(current_app_bundle_id)
        puts "app name: #{app.name} | bundle id: #{app.bundle_id}"
        app
      end

      def current_tab
        `osascript -e 'tell application "Google Chrome" to get title of active tab of front window'`.strip
      end
    end
  end
end
