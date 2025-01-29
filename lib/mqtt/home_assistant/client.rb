# frozen_string_literal: true

require "mqtt/client"

module MQTT
  module HomeAssistant
    module Client
      KNOWN_ATTRIBUTES.each_key do |platform|
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

      def publish_hass_component(object_id, platform:, discovery_prefix: "homeassistant", node_id: nil, **kwargs)
        node_and_object_id = node_id ? "#{node_id}/#{object_id}" : object_id
        unless KNOWN_ATTRIBUTES.key?(platform)
          raise ArgumentError, "Unknown platform #{platform} for #{node_and_object_id}"
        end

        required_attributes = attributes_for_schema(REQUIRED_ATTRIBUTES, platform, kwargs)
        if required_attributes
          missing_attributes = required_attributes - kwargs.keys
          unless missing_attributes&.empty?
            raise ArgumentError,
                  "Missing attribute(s) #{missing_attributes.join(", ")} for #{platform}/#{node_and_object_id}"
          end
        end

        known_attributes = attributes_for_schema(KNOWN_ATTRIBUTES, platform, kwargs)
        unknown_attributes = kwargs.keys - SPECIAL_ATTRIBUTES[:common] - known_attributes
        unless unknown_attributes.empty?
          raise ArgumentError,
                "Unknown attribute(s) #{unknown_attributes.join(", ")} for #{platform}/#{node_and_object_id}"
        end

        if (availability_list = kwargs[:availability])
          unless (kwargs.keys & %i[availability_mode
                                   availability_template
                                   availability_topic
                                   payload_available
                                   payload_not_available]).empty?
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

        if (device = kwargs[:device])
          raise ArgumentError, "device must be a hash for #{platform}/#{node_and_object_id}" unless device.is_a?(Hash)
          unless (extra_keys = device.keys - SPECIAL_ATTRIBUTES[:device]).empty?
            raise ArgumentError, "Unknown attribute(s) #{extra_keys} for #{platform}/#{node_and_object_id}'s device"
          end
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

        RANGE_ATTRIBUTES[platform]&.each do |attr, prefix_or_suffix|
          range_name = (prefix_or_suffix == :singleton) ? attr : :"#{attr}_range"
          if (range = kwargs.delete(range_name))
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
        end

        publish("#{discovery_prefix || "homeassistant"}/#{platform}/#{node_and_object_id}/config",
                kwargs.to_json,
                retain: true,
                qos: 1)
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
    end
  end
  Client.include(HomeAssistant::Client)
end
