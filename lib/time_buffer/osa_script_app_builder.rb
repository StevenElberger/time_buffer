# frozen_string_literal: true

module TimeBuffer
  class OsaScriptAppBuilder
    class << self
      REGISTRY = {}

      def register(app_bundle_id:, app_class:)
        REGISTRY[app_bundle_id] = app_class
      end

      def build(app_bundle_id)
        app_class = REGISTRY[app_bundle_id]

        if app_class.nil?
          OsaScriptApp.new(app_bundle_id)
        else
          app_class.new(app_bundle_id)
        end
      end
    end
  end
end
