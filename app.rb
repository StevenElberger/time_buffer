# frozen_string_literal: true

previous_app = nil
previous_tab = nil

loop do
  current_app = `osascript -e 'id of application (path to frontmost application as text)'`.strip
  app_name = case current_app
             when "com.microsoft.VSCode"
               "Visual Studio Code"
             when "com.google.Chrome"
               "Google Chrome"
             else
               `osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true'`.strip
             end

  if app_name == "Google Chrome"
    current_tab = `osascript -e 'tell application "Google Chrome" to get title of active tab of front window'`.strip
    if current_tab != previous_tab
      puts "Active Chrome tab changed to: #{current_tab}"
      previous_tab = current_tab
    end
  end

  if app_name != previous_app
    puts "Active application changed to: #{app_name}"
    previous_app = app_name
  end

  sleep 1
end
