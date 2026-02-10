# frozen_string_literal: true

require "pycall/import"

begin
  PyCall.sys.path.append(File.expand_path(File.join(__dir__, "../../../python")))
rescue PyCall::PythonNotFound
  raise LoadError
end

module HomeAssistant
  module MQTT
    module Discovery
      extend PyCall::Import

      begin
        pyfrom "homeassistant.components.mqtt.discovery", import: :process_discovery_config
      rescue PyCall::PyError => e
        if e.type == PyCall.builtins.ModuleNotFoundError
          MQTT.send(:remove_const, :Discovery)
          raise LoadError, e
        end

        raise
      end
    end
  end
end
