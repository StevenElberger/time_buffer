# frozen_string_literal: true

module TimeBuffer
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

      def current_tab
        `osascript -e 'tell application "Google Chrome" to get title of active tab of front window'`.strip
      end
    end
  end
end
