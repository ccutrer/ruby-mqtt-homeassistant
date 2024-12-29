# frozen_string_literal: true

require "json"

require "mqtt-homie-homeassistant"

module MQTT
  module HomeAssistant
    SPECIAL_ATTRIBUTES = {
      common: %i[
        availability
        availability_mode
        availability_template
        availability_topic
        device
        enabled_by_default
        entity_category
        entity_picture
        icon
        json_attributes_template
        json_attributes_topic
        name
        optimistic
        payload_available
        payload_not_available
        platform
        qos
        retain
        unique_id
      ].freeze,
      availability: %i[
        payload_available
        payload_not_available
        topic
        value_template
      ].freeze,
      device: %i[
        configuration_url
        connections
        hw_version
        identifiers
        manufacturer
        model
        model_id
        name
        serial_number
        suggested_area
        sw_version
        via_device
      ].freeze
    }.freeze
    KNOWN_ATTRIBUTES = {
      binary_sensor: %i[
        state_topic
        device_class
        expire_after
        force_update
        off_delay
        payload_off
        payload_on
      ].freeze,
      climate: %i[
        action_template
        action_topic
        current_humidity_template
        current_humidity_topic
        current_temperature_template
        current_temperature_topic
        fan_mode_command_template
        fan_mode_command_topic
        fan_mode_state_template
        fan_mode_state_topic
        fan_modes
        humidity_range
        initial
        max_humidity
        max_temp
        min_humidity
        min_temp
        mode_command_template
        mode_command_topic
        mode_state_template
        mode_state_topic
        modes
        payload_off
        payload_on
        power_command_template
        power_command_topic
        power_state_template
        power_state_topic
        precision
        preset_mode_command_template
        preset_mode_command_topic
        preset_mode_state_topic
        preset_mode_value_template
        preset_modes
        swing_mode_command_template
        swing_mode_command_topic
        swing_mode_state_template
        swing_mode_state_topic
        swing_modes
        target_humidity_command_template
        target_humidity_command_topic
        target_humidity_state_template
        target_humidity_state_topic
        temp_range
        temp_step
        temperature_command_template
        temperature_command_topic
        temperature_high_command_template
        temperature_high_command_topic
        temperature_high_state_template
        temperature_high_state_topic
        temperature_low_command_template
        temperature_low_command_topic
        temperature_low_state_template
        temperature_low_state_topic
        temperature_state_template
        temperature_state_topic
        temperature_unit
        value_template
      ].freeze,
      fan: %i[
        command_topic:
        command_template
        direction_command_template
        direction_command_topic
        direction_state_topic
        direction_value_template
        oscillation_command_template
        oscillation_command_topic
        oscillation_state_topic
        oscillation_value_template
        payload_off
        payload_on
        payload_oscillation_off
        payload_oscillation_on
        payload_reset_percentage
        payload_reset_preset_mode
        percentage_command_template
        percentage_command_topic
        percentage_state_topic
        percentage_value_template
        preset_mode_command_template
        preset_mode_command_topic
        preset_mode_state_topic
        preset_mode_value_template
        preset_modes
        speed_range
        state_topic
        state_value_template
      ].freeze,
      humidifier: %i[
        action_template
        action_topic
        current_humidity_template
        current_humidity_topic
        command_template
        command_topic
        device_class
        mode_command_template
        mode_command_topic
        mode_staet_template
        mode_state_topic
        modes
        payload_off
        payload_on
        payload_reset_humidity
        payload_reset_mode
        state_topic
        target_humidity_command_template
        target_humidity_command_topic
        target_humidity_state_topic
        target_humidity_state_template
      ].freeze,
      light: {
        default: %i[
          brightness_command_template
          brightness_command_topic
          brightness_scale
          brightness_state_topic
          brightness_value_template
          color_mode_state_topic
          color_mode_value_template
          color_temp_command_template
          color_temp_command_topic
          color_temp_state_topic
          color_temp_value_template
          command_topic
          effect_command_topic
          effect_command_template
          effect_list
          effect_state_topic
          effect_value_template
          hs_command_template
          hs_command_topic
          hs_state_topic
          hs_value_template
          max_mireds
          min_mireds
          mireds_range
          on_command_type
          payload_off
          payload_on
          rgb_command_template
          rgb_command_topic
          rgb_state_topic
          rgb_value_template
          rgbw_command_template
          rgbw_command_topic
          rgbw_state_topic
          rgbw_value_template
          rgbww_command_template
          rgbww_command_topic
          rgbww_state_topic
          rgbww_value_template
          state_topic
          white_command_topic
          white_scale
          xy_command_template
          xy_command_topic
          xy_state_topic
          xy_value_template
        ].freeze,
        json: %i[
          brightness
          brightness_scale
          command_topic
          effect
          effect_list
          flash_time_long
          flash_time_short
          max_mireds
          min_mireds
          mireds_range
          state_topic
          supported_color_modes
          white_scale
        ].freeze,
        template: %i[
          blue_template
          brightness_template
          color_temp_template
          command_off_template
          command_on_template
          command_topic
          effect_list
          effect_template
          green_template
          max_mireds
          min_mireds
          mireds_range
          red_template
          state_template
          state_topic
        ].freeze
      }.freeze,
      number: %i[
        command_template
        command_topic
        min
        max
        mode
        payload_reset
        range
        state_topic
        step
        unit_of_measurement
        value_template
      ].freeze,
      scene: %i[
        command_topic
        payload_on
      ].freeze,
      select: %i[
        command_template
        command_topic
        options
        state_topic
        value_template
      ].freeze,
      sensor: %i[
        device_class
        expire_after
        force_update
        last_reset_value_template
        options
        suggested_display_precision
        state_class
        state_topic
        unit_of_measurement
        value_template
      ].freeze,
      switch: %i[
        command_template
        command_topic
        device_class
        payload_off
        payload_on
        state_off
        state_on
        state_topic
        value_template
      ].freeze,
      water_heater: %i[
        current_temperature_template
        current_temperature_topic
        initial
        max_temp
        min_temp
        mode_command_template
        mode_command_topic
        mode_state_template
        mode_state_topic
        modes
        payload_off
        payload_on
        power_command_template
        power_command_topic
        precision
        range
        temperature_command_template
        temperature_command_topic
        temperature_state_template
        temperature_state_topic
        temperature_unit
        value_template
      ]
    }.freeze

    RANGE_ATTRIBUTES = {
      climate: { humidity: :prefix, temp: :prefix }.freeze,
      fan: { speed_range: :suffix }.freeze,
      humidifier: { humidity: :prefix }.freeze,
      light: { mireds: :prefix }.freeze,
      number: { range: :singleton }.freeze,
      water_heater: { range: :singleton }.freeze
    }.freeze

    REQUIRED_ATTRIBUTES = {
      binary_sensor: %i[state_topic].freeze,
      humidifier: %i[command_topic target_humidity_command_topic].freeze,
      light: {
        default: %i[command_topic].freeze,
        json: %i[command_topic].freeze,
        template: %i[command_off_template command_on_template command_topic]
      }.freeze,
      number: %i[command_topic].freeze,
      select: %i[command_topic options].freeze,
      sensor: %i[state_topic].freeze,
      switch: %i[command_topic].freeze
    }.freeze

    DEFAULTS = {
      binary_sensor: {
        payload_off: "OFF",
        payload_on: "ON"
      }.freeze,
      climate: {
        fan_modes: %w[auto low medium high].freeze,
        modes: %w[auto off cool heat dry fan_only].freeze,
        swing_modes: %w[on off].freeze
      }.freeze,
      fan: {
        payload_off: "off",
        payload_on: "on"
      }.freeze,
      humidifier: {
        device_class: "humidifier",
        payload_off: "OFF",
        payload_on: "ON",
        payload_reset_humidity: "None",
        payload_reset_mode: "None"
      }.freeze,
      light: {
        payload_off: "OFF",
        payload_on: "ON"
      }.freeze,
      number: {
        mode: "auto",
        payload_reset: "None"
      }.freeze,
      scene: {
        payload_on: "ON"
      },
      switch: {
        payload_off: "OFF",
        payload_on: "ON"
      }.freeze,
      water_heater: {
        modes: %i[off eco electric gas heat_pump high_demand performance].freeze,
        payload_off: "OFF",
        payload_on: "ON"
      }.freeze
    }.freeze

    VALIDATIONS = {
      light: lambda do |supported_color_modes: nil, **|
        if supported_color_modes && supported_color_modes.length > 1 &&
           (supported_color_modes.include?(:onoff) || supported_color_modes.include?(:brightness))
          raise ArgumentError,
                "Multiple color modes are not supported for platform light if onoff or brightness are specified"
        end
      end
    }.freeze

    SUBSET_VALIDATIONS = {
      climate: {
        modes: DEFAULTS[:climate][:modes]
      }.freeze,
      light: {
        supported_color_modes: %i[onoff brightness color_temp hs xy rgb rgbw rgbww white].freeze
      }.freeze,
      water_heater: {
        modes: DEFAULTS[:water_heater][:modes]
      }
    }.freeze
    INCLUSION_VALIDATIONS = {
      common: {
        entity_category: %i[config diagnostic system].freeze
      }.freeze,
      binary_sensor: {
        device_class: %i[
          battery
          battery_charging
          carbon_monoxide
          cold
          connectivity
          door
          garage_door
          gas
          heat
          light
          lock
          moisture
          motion
          moving
          occupancy
          opening
          plug
          power
          presence
          problem
          running
          safety
          smoke
          sound
          tamper
          update
          vibration
          window
        ].to_set.freeze
      }.freeze,
      humidifier: {
        device_class: %i[
          humidifier
          dehumidifier
        ].freeze
      }.freeze,
      light: {
        on_command_type: %i[last first brightness].freeze
      }.freeze,
      sensor: {
        device_class: %i[
          apparent_power
          aqi
          atmospheric_pressure
          battery
          carbon_dioxide
          carbon_monoxide
          current
          data_rate
          data_size
          date
          distance
          duration
          energy
          energy_storage
          enum
          frequency
          gas
          humidity
          illuminance
          irradiance
          moisture
          monetary
          nitrogen_dioxide
          nitrogen_monoxide
          nitrous_oxide
          ozone
          ph
          pm1
          pm10
          pm25
          power_factor
          power
          precipitation
          precipitation_intensity
          pressure
          reactive_power
          signal_strength
          sound_pressure
          speed
          sulphur_dioxide
          temperature
          timestamp
          volatile_organic_compounds
          volatile_organic_compounds_parts
          voltage
          volume
          volume_storage
          water
          weight
          wind_speed
        ].to_set.freeze,
        state_class: %i[measurement total total_increasing].freeze
      }.freeze
    }.freeze
  end
end

require "mqtt/home_assistant/client"
