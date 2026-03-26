# frozen_string_literal: true

require "mqtt/client"

begin
  require "home_assistant/mqtt/discovery"
rescue LoadError
  # ignore
end

module MQTT
  module HomeAssistant
    module Client
      KNOWN_ATTRIBUTES.each_key do |platform|
        next if platform == :device

        class_eval <<~RUBY, __FILE__, __LINE__ + 1
          def publish_hass_#{platform}(object_id, platform: #{platform.inspect}, **kwargs)
            raise ArgumentError, "platform must be #{platform.inspect}" unless platform == #{platform.inspect}

            publish_hass_component(object_id, platform: platform, **kwargs)
          end

          def unpublish_hass_#{platform}(object_id, platform: #{platform.inspect}, **kwargs)
            raise ArgumentError, "platform must be #{platform.inspect}" unless platform == #{platform.inspect}

            unpublish_hass_component(object_id, platform: platform, **kwargs)
          end
        RUBY
      end

      def unpublish_hass_component(object_id, platform:, discovery_prefix: "homeassistant", node_id: nil)
        node_and_object_id = node_id ? "#{node_id}/#{object_id}" : object_id
        unless KNOWN_ATTRIBUTES.key?(platform)
          raise ArgumentError, "Unknown platform #{platform} for #{node_and_object_id}"
        end

        publish("#{discovery_prefix || "homeassistant"}/#{platform}/#{node_and_object_id}/config",
                "",
                retain: true,
                qos: 1)
      end

      def publish_hass_device(device_id, discovery_prefix: "homeassistant", migrate_discovery: false, **kwargs)
        raise ArgumentError, "components cannot be passed as an argument" if kwargs[:components]

        validate_hass_common(kwargs, :device, device_id)

        @collected_hass_components = {}
        begin
          yield
        ensure
          kwargs[:components] = @collected_hass_components
          @collected_hass_components = nil
        end

        unless defined?(::HomeAssistant::MQTT::Discovery)
          missing_attributes = REQUIRED_ATTRIBUTES[:device] - kwargs.keys
          unless missing_attributes.empty?
            raise ArgumentError, "Missing attribute(s) #{missing_attributes.join(", ")} for device/#{device_id}"
          end
        end

        hass_abbreviate(ABBREVIATIONS, kwargs)

        if migrate_discovery
          kwargs[:cmps].each do |object_id, component|
            hass_publish(discovery_prefix,
                         component[:p],
                         "#{device_id}/#{object_id}",
                         MIGRATE_DISCOVERY_JSON,
                         validate: false)
          end
        end

        hass_publish(discovery_prefix, :device, device_id, kwargs.to_json)

        return unless migrate_discovery

        kwargs[:cmps].each do |object_id, component|
          hass_publish(discovery_prefix, component[:p], "#{device_id}/#{object_id}", "", validate: false)
        end
      end

      def publish_hass_component(object_id, platform:, discovery_prefix: "homeassistant", node_id: nil, **kwargs)
        raise ArgumentError, "Use `publish_hass_device` for device discovery" if platform == :device

        node_and_object_id = node_id ? "#{node_id}/#{object_id}" : object_id

        validate_hass_common(kwargs, platform, node_and_object_id)

        unless defined?(::HomeAssistant::MQTT::Discovery)
          unless KNOWN_ATTRIBUTES.key?(platform)
            raise ArgumentError, "Unknown platform #{platform} for #{node_and_object_id}"
          end

          required_attributes = attributes_for_schema(REQUIRED_ATTRIBUTES, platform, kwargs)
          required_attributes += [:unique_id] if @collected_hass_components && ENTITY_PLATFORMS.include?(platform)
          missing_attributes = required_attributes - kwargs.keys
          unless missing_attributes.empty?
            raise ArgumentError,
                  "Missing attribute(s) #{missing_attributes.join(", ")} for #{platform}/#{node_and_object_id}"
          end

          known_attributes = attributes_for_schema(KNOWN_ATTRIBUTES, platform, kwargs)
          unknown_attributes = kwargs.keys - SPECIAL_ATTRIBUTES[:common] - known_attributes
          unless unknown_attributes.empty?
            raise ArgumentError,
                  "Unknown attribute(s) #{unknown_attributes.join(", ")} for #{platform}/#{node_and_object_id}"
          end

          if @collected_hass_components &&
             !(extra_keys = DISALLOWED_COMPONENT_ATTRIBUTES_WHEN_DEVICE & kwargs.keys).empty?
            raise ArgumentError, "Unknown attribute(s) #{extra_keys} for #{platform}/#{node_and_object_id}"
          end

          INCLUSION_VALIDATIONS[:common].merge(INCLUSION_VALIDATIONS[platform] || {}).each do |attr, valid_values|
            if (value = kwargs[attr]) && !valid_values.include?(value)
              raise ArgumentError, "Unrecognized #{attr} #{value} for #{platform}/#{node_and_object_id}"
            end
          end
          SUBSET_VALIDATIONS[platform]&.each do |attr, valid_values|
            if (values = kwargs[attr]) && !(extra_values = values - valid_values).empty?
              raise ArgumentError, "Invalid #{attr} #{extra_values.join(", ")} for #{platform}/#{node_and_object_id}"
            end
          end

          VALIDATIONS[platform]&.call(**kwargs)
        end

        RANGE_ATTRIBUTES[platform]&.each do |attr, prefix_or_suffix|
          range_name = (prefix_or_suffix == :singleton) ? attr : :"#{attr}_range"
          next unless (range = kwargs.delete(range_name))

          case prefix_or_suffix
          when :prefix
            kwargs[:"min_#{attr}"] = range.begin
            kwargs[:"max_#{attr}"] = range.end
          when :suffix
            kwargs[:"#{attr}_min"] = range.begin
            kwargs[:"#{attr}_max"] = range.end
          when :singleton
            kwargs[:min] = range.begin
            kwargs[:max] = range.end
          end
        end

        hass_abbreviate(ABBREVIATIONS, kwargs)
        if @collected_hass_components
          kwargs[:p] = platform
          @collected_hass_components[object_id] = kwargs
        else
          hass_publish(discovery_prefix, platform, node_and_object_id, kwargs.to_json)
        end
      end

      private

      def attributes_for_schema(hash, platform, kwargs)
        attributes = hash[platform]
        if attributes.is_a?(Hash)
          schema = kwargs[:schema] || :default
          attributes = attributes[schema]
          raise ArgumentError, "Invalid schema #{schema} for platform #{platfomr}" unless attributes
        end

        attributes
      end

      def hass_publish(discovery_prefix, platform, node_and_object_id, json, validate: true)
        if defined?(::HomeAssistant::MQTT::Discovery) && validate
          begin
            ::HomeAssistant::MQTT::Discovery.process_discovery_config(
              "#{platform}/#{node_and_object_id}/config", json
            )
          rescue PyCall::PyError => e
            raise ArgumentError, e
          end
        end

        publish("#{discovery_prefix || "homeassistant"}/#{platform}/#{node_and_object_id}/config",
                json,
                retain: true,
                qos: 1)
      end

      def validate_hass_common(kwargs, platform, node_and_object_id)
        validate_hass_availability(kwargs, platform, node_and_object_id)
        validate_hass_special(:device, kwargs, platform, node_and_object_id, DEVICE_ABBREVIATIONS)
        validate_hass_special(:origin, kwargs, platform, node_and_object_id, ORIGIN_ABBREVIATIONS)
      end

      def validate_hass_availability(kwargs, platform, node_and_object_id)
        return if defined?(::HomeAssistant::MQTT::Discovery)

        if (availability_list = kwargs[:availability])
          if kwargs.keys.intersect?(%i[availability_mode
                                       availability_template
                                       availability_topic
                                       payload_available
                                       payload_not_available])
            raise ArgumentError,
                  "availability cannot be used together with availability topic for #{platform}/#{node_and_object_id}"
          end

          availability_list = [availability_list] if availability_list.is_a?(Hash)
          unless availability_list.is_a?(Array)
            raise ArgumentError, "availability must be an array for #{platform}/#{node_and_object_id}"
          end

          availability_list.each do |availability|
            unless availability.key?(:topic)
              raise ArgumentError, "availability must have a topic for #{platform}/#{node_and_object_id}"
            end

            unless (extra_keys = availability.keys - SPECIAL_ATTRIBUTES[:availability]).empty?
              raise ArgumentError,
                    "Unknown attribute(s) #{extra_keys} for #{platform}/#{node_and_object_id}'s availability"
            end
          end
        end
      end

      def validate_hass_special(special_type, kwargs, platform, node_and_object_id, abbreviations)
        if (config = kwargs[special_type])
          unless defined?(::HomeAssistant::MQTT::Discovery)
            unless config.is_a?(Hash)
              raise ArgumentError,
                    "#{special_type} must be a hash for #{platform}/#{node_and_object_id}"
            end
            unless (extra_keys = config.keys - SPECIAL_ATTRIBUTES[special_type]).empty?
              raise ArgumentError,
                    "Unknown attribute(s) #{extra_keys} for #{platform}/#{node_and_object_id}'s #{special_type}"
            end
          end

          kwargs[special_type] = hass_abbreviate(abbreviations, config)
        end
      end

      def hass_abbreviate(abbreviations, kwargs)
        kwargs.transform_keys { |key| abbreviations[key.to_s] || key }
      end
    end
  end
  Client.include(HomeAssistant::Client)
end
