# frozen_string_literal: true

require "json"

module MQTT
  module HomeAssistant
    ABBREVIATIONS = {
      act_t: "action_topic",
      act_tpl: "action_template",
      act_stat_t: "activity_state_topic",
      act_val_tpl: "activity_value_template",
      atype: "automation_type",
      av_tones: "available_tones",
      avty: "availability",
      avty_mode: "availability_mode",
      avty_t: "availability_topic",
      avty_tpl: "availability_template",
      b_tpl: "blue_template",
      bri_cmd_tpl: "brightness_command_template",
      bri_cmd_t: "brightness_command_topic",
      bri_scl: "brightness_scale",
      bri_stat_t: "brightness_state_topic",
      bri_tpl: "brightness_template",
      bri_val_tpl: "brightness_value_template",
      clr_temp_cmd_tpl: "color_temp_command_template",
      clrm: "color_mode",
      clrm_stat_t: "color_mode_state_topic",
      clrm_val_tpl: "color_mode_value_template",
      clr_temp_cmd_t: "color_temp_command_topic",
      clr_temp_k: "color_temp_kelvin",
      clr_temp_stat_t: "color_temp_state_topic",
      clr_temp_tpl: "color_temp_template",
      clr_temp_val_tpl: "color_temp_value_template",
      cmd_off_tpl: "command_off_template",
      cmd_on_tpl: "command_on_template",
      cmd_t: "command_topic",
      cmd_tpl: "command_template",
      cmps: "components",
      cod_arm_req: "code_arm_required",
      cod_dis_req: "code_disarm_required",
      cod_form: "code_format",
      cod_trig_req: "code_trigger_required",
      cont_type: "content_type",
      curr_hum_t: "current_humidity_topic",
      curr_hum_tpl: "current_humidity_template",
      curr_temp_t: "current_temperature_topic",
      curr_temp_tpl: "current_temperature_template",
      def_ent_id: "default_entity_id",
      dev: "device",
      dev_cla: "device_class",
      dir_cmd_t: "direction_command_topic",
      dir_cmd_tpl: "direction_command_template",
      dir_stat_t: "direction_state_topic",
      dir_val_tpl: "direction_value_template",
      dsp_prc: "display_precision",
      dock_cmd_t: "dock_command_topic",
      dock_cmd_tpl: "dock_command_template",
      e: "encoding",
      en: "enabled_by_default",
      ent_cat: "entity_category",
      ent_pic: "entity_picture",
      evt_typ: "event_types",
      fanspd_lst: "fan_speed_list",
      flsh: "flash",
      flsh_tlng: "flash_time_long",
      flsh_tsht: "flash_time_short",
      fx_cmd_tpl: "effect_command_template",
      fx_cmd_t: "effect_command_topic",
      fx_list: "effect_list",
      fx_stat_t: "effect_state_topic",
      fx_tpl: "effect_template",
      fx_val_tpl: "effect_value_template",
      exp_aft: "expire_after",
      fan_mode_cmd_tpl: "fan_mode_command_template",
      fan_mode_cmd_t: "fan_mode_command_topic",
      fan_mode_stat_tpl: "fan_mode_state_template",
      fan_mode_stat_t: "fan_mode_state_topic",
      frc_upd: "force_update",
      g_tpl: "green_template",
      hs_cmd_t: "hs_command_topic",
      hs_cmd_tpl: "hs_command_template",
      hs_stat_t: "hs_state_topic",
      hs_val_tpl: "hs_value_template",
      ic: "icon",
      img_e: "image_encoding",
      img_t: "image_topic",
      init: "initial",
      hum_cmd_t: "target_humidity_command_topic",
      hum_cmd_tpl: "target_humidity_command_template",
      hum_stat_t: "target_humidity_state_topic",
      hum_state_tpl: "target_humidity_state_template",
      json_attr: "json_attributes",
      json_attr_t: "json_attributes_topic",
      json_attr_tpl: "json_attributes_template",
      lrst_val_tpl: "last_reset_value_template",
      max: "max",
      min: "min",
      max_hum: "max_humidity",
      min_hum: "min_humidity",
      max_mirs: "max_mireds",
      min_mirs: "min_mireds",
      max_k: "max_kelvin",
      min_k: "min_kelvin",
      max_temp: "max_temp",
      min_temp: "min_temp",
      migr_discvry: "migrate_discovery",
      mode: "mode",
      mode_cmd_tpl: "mode_command_template",
      mode_cmd_t: "mode_command_topic",
      mode_stat_t: "mode_state_topic",
      mode_stat_tpl: "mode_state_template",
      modes: "modes",
      name: "name",
      o: "origin",
      obj_id: "object_id",
      off_dly: "off_delay",
      on_cmd_type: "on_command_type",
      ops: "options",
      opt: "optimistic",
      osc_cmd_t: "oscillation_command_topic",
      osc_cmd_tpl: "oscillation_command_template",
      osc_stat_t: "oscillation_state_topic",
      osc_val_tpl: "oscillation_value_template",
      p: "platform",
      pause_cmd_t: "pause_command_topic",
      pause_mw_cmd_tpl: "pause_command_template",
      pct_cmd_t: "percentage_command_topic",
      pct_cmd_tpl: "percentage_command_template",
      pct_stat_t: "percentage_state_topic",
      pct_val_tpl: "percentage_value_template",
      pl: "payload",
      pl_arm_away: "payload_arm_away",
      pl_arm_home: "payload_arm_home",
      pl_arm_nite: "payload_arm_night",
      pl_arm_vacation: "payload_arm_vacation",
      pl_arm_custom_b: "payload_arm_custom_bypass",
      pl_avail: "payload_available",
      pl_cln_sp: "payload_clean_spot",
      pl_cls: "payload_close",
      pl_disarm: "payload_disarm",
      pl_home: "payload_home",
      pl_lock: "payload_lock",
      pl_loc: "payload_locate",
      pl_not_avail: "payload_not_available",
      pl_not_home: "payload_not_home",
      pl_off: "payload_off",
      pl_on: "payload_on",
      pl_open: "payload_open",
      pl_osc_off: "payload_oscillation_off",
      pl_osc_on: "payload_oscillation_on",
      pl_paus: "payload_pause",
      pl_prs: "payload_press",
      pl_rst: "payload_reset",
      pl_rst_hum: "payload_reset_humidity",
      pl_rst_mode: "payload_reset_mode",
      pl_rst_pct: "payload_reset_percentage",
      pl_rst_pr_mode: "payload_reset_preset_mode",
      pl_stop: "payload_stop",
      pl_stop_tilt: "payload_stop_tilt",
      pl_strt: "payload_start",
      pl_ret: "payload_return_to_base",
      pl_toff: "payload_turn_off",
      pl_ton: "payload_turn_on",
      pl_trig: "payload_trigger",
      pl_unlk: "payload_unlock",
      pos: "reports_position",
      pos_clsd: "position_closed",
      pos_open: "position_open",
      pow_cmd_t: "power_command_topic",
      pow_cmd_tpl: "power_command_template",
      pr_mode_cmd_t: "preset_mode_command_topic",
      pr_mode_cmd_tpl: "preset_mode_command_template",
      pr_mode_stat_t: "preset_mode_state_topic",
      pr_mode_val_tpl: "preset_mode_value_template",
      pr_modes: "preset_modes",
      ptrn: "pattern",
      r_tpl: "red_template",
      rel_s: "release_summary",
      rel_u: "release_url",
      ret: "retain",
      rgb_cmd_tpl: "rgb_command_template",
      rgb_cmd_t: "rgb_command_topic",
      rgb_stat_t: "rgb_state_topic",
      rgb_val_tpl: "rgb_value_template",
      rgbw_cmd_tpl: "rgbw_command_template",
      rgbw_cmd_t: "rgbw_command_topic",
      rgbw_stat_t: "rgbw_state_topic",
      rgbw_val_tpl: "rgbw_value_template",
      rgbww_cmd_tpl: "rgbww_command_template",
      rgbww_cmd_t: "rgbww_command_topic",
      rgbww_stat_t: "rgbww_state_topic",
      rgbww_val_tpl: "rgbww_value_template",
      send_cmd_t: "send_command_topic",
      send_if_off: "send_if_off",
      set_fan_spd_t: "set_fan_speed_topic",
      set_pos_tpl: "set_position_template",
      set_pos_t: "set_position_topic",
      pos_t: "position_topic",
      pos_tpl: "position_template",
      spd_rng_min: "speed_range_min",
      spd_rng_max: "speed_range_max",
      src_type: "source_type",
      stat_cla: "state_class",
      stat_clsd: "state_closed",
      stat_closing: "state_closing",
      stat_jam: "state_jammed",
      stat_off: "state_off",
      stat_on: "state_on",
      stat_open: "state_open",
      stat_opening: "state_opening",
      stat_stopped: "state_stopped",
      stat_locked: "state_locked",
      stat_locking: "state_locking",
      stat_unlocked: "state_unlocked",
      stat_unlocking: "state_unlocking",
      stat_t: "state_topic",
      stat_tpl: "state_template",
      stat_val_tpl: "state_value_template",
      step: "step",
      strt_mw_cmd_t: "start_mowing_command_topic",
      strt_mw_cmd_tpl: "start_mowing_command_template",
      stype: "subtype",
      sug_dsp_prc: "suggested_display_precision",
      sup_dur: "support_duration",
      sup_vol: "support_volume_set",
      sup_feat: "supported_features",
      sup_clrm: "supported_color_modes",
      swing_h_mode_cmd_tpl: "swing_horizontal_mode_command_template",
      swing_h_mode_cmd_t: "swing_horizontal_mode_command_topic",
      swing_h_mode_stat_tpl: "swing_horizontal_mode_state_template",
      swing_h_mode_stat_t: "swing_horizontal_mode_state_topic",
      swing_h_modes: "swing_horizontal_modes",
      swing_mode_cmd_tpl: "swing_mode_command_template",
      swing_mode_cmd_t: "swing_mode_command_topic",
      swing_mode_stat_tpl: "swing_mode_state_template",
      swing_mode_stat_t: "swing_mode_state_topic",
      swing_modes: "swing_modes",
      temp_cmd_tpl: "temperature_command_template",
      temp_cmd_t: "temperature_command_topic",
      temp_hi_cmd_tpl: "temperature_high_command_template",
      temp_hi_cmd_t: "temperature_high_command_topic",
      temp_hi_stat_tpl: "temperature_high_state_template",
      temp_hi_stat_t: "temperature_high_state_topic",
      temp_lo_cmd_tpl: "temperature_low_command_template",
      temp_lo_cmd_t: "temperature_low_command_topic",
      temp_lo_stat_tpl: "temperature_low_state_template",
      temp_lo_stat_t: "temperature_low_state_topic",
      temp_stat_tpl: "temperature_state_template",
      temp_stat_t: "temperature_state_topic",
      temp_unit: "temperature_unit",
      tilt_clsd_val: "tilt_closed_value",
      tilt_cmd_t: "tilt_command_topic",
      tilt_cmd_tpl: "tilt_command_template",
      tilt_max: "tilt_max",
      tilt_min: "tilt_min",
      tilt_opnd_val: "tilt_opened_value",
      tilt_opt: "tilt_optimistic",
      tilt_status_t: "tilt_status_topic",
      tilt_status_tpl: "tilt_status_template",
      tit: "title",
      t: "topic",
      trns: "transition",
      uniq_id: "unique_id",
      unit_of_meas: "unit_of_measurement",
      url_t: "url_topic",
      url_tpl: "url_template",
      val_tpl: "value_template",
      whit_cmd_t: "white_command_topic",
      whit_scl: "white_scale",
      xy_cmd_t: "xy_command_topic",
      xy_cmd_tpl: "xy_command_template",
      xy_stat_t: "xy_state_topic",
      xy_val_tpl: "xy_value_template",
      l_ver_t: "latest_version_topic",
      l_ver_tpl: "latest_version_template",
      pl_inst: "payload_install"
    }.invert.freeze

    DEVICE_ABBREVIATIONS = {
      cns: "connections",
      cu: "configuration_url",
      ids: "identifiers",
      name: "name",
      mf: "manufacturer",
      mdl: "model",
      mdl_id: "model_id",
      hw: "hw_version",
      sw: "sw_version",
      sa: "suggested_area",
      sn: "serial_number"
    }.invert.freeze

    ORIGIN_ABBREVIATIONS = {
      name: "name",
      sw: "sw_version",
      url: "support_url"
    }.invert.freeze

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
        object_id
        optimistic
        origin
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
      ].freeze,
      origin: %i[
        name
        support_url
        sw_version
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
      button: %i[
        command_template
        command_topic
        device_class
        payload_press
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
      cover: %i[
        command_topic
        device_class
        payload_close
        payload_open
        payload_stop
        position_closed
        position_open
        position_template
        position_topic
        set_position_template
        set_position_topic
        state_closed
        state_closing
        state_open
        state_opening
        state_stopped
        state_topic
        tilt_closed_value
        tilt_command_topic
        tilt_max
        tilt_min
        tilt_opened_value
        tilt_optimistic
        tilt_range
        tilt_status_template
        value_template
      ].freeze,
      device: %i[
        availability
        availability_mode
        availability_template
        availability_topic
        command_topic
        device
        encoding
        origin
        payload_available
        payload_not_available
        qos
        state_topic
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
      text: %i[
        command_template
        command_topic
        min
        max
        range
        mode
        pattern
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
      cover: { tilt: :suffix }.freeze,
      fan: { speed: :suffix }.freeze,
      humidifier: { humidity: :prefix }.freeze,
      light: { mireds: :prefix }.freeze,
      number: { range: :singleton }.freeze,
      text: { range: :singleton }.freeze,
      water_heater: { range: :singleton }.freeze
    }.freeze

    REQUIRED_ATTRIBUTES = Hash.new([].freeze).merge(
      {
        binary_sensor: %i[state_topic].freeze,
        button: %i[command_topic].freeze,
        device: %i[components device origin].freeze,
        humidifier: %i[command_topic
                       target_humidity_command_topic].freeze,
        light: {
          default: %i[command_topic].freeze,
          json: %i[command_topic].freeze,
          template: %i[command_off_template
                       command_on_template
                       command_topic]
        }.freeze,
        number: %i[command_topic].freeze,
        select: %i[command_topic options].freeze,
        sensor: %i[state_topic].freeze,
        switch: %i[command_topic].freeze,
        text: %i[command_topic].freeze
      }
    ).freeze

    DISALLOWED_COMPONENT_ATTRIBUTES_WHEN_DEVICE = %w[
      availability
      device
    ].freeze

    DEFAULTS = {
      binary_sensor: {
        payload_off: "OFF",
        payload_on: "ON"
      }.freeze,
      button: {
        payload_press: "PRESS"
      }.freeze,
      climate: {
        fan_modes: %w[auto low medium high].freeze,
        modes: %w[auto off cool heat dry fan_only].freeze,
        swing_modes: %w[on off].freeze
      }.freeze,
      cover: {
        payload_close: "CLOSE",
        payload_open: "OPEN",
        payload_stop: "STOP",
        state_closed: "closed",
        state_closing: "closing",
        state_open: "open",
        state_opening: "opening",
        state_stopped: "stopped"
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
      text: {
        mode: "text"
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
      button: {
        device_class: %i[
          identify
          restart
          update
        ].freeze
      }.freeze,
      cover: {
        device_class: %i[
          awning
          blind
          curtain
          damper
          door
          garage
          gate
          shade
          shutter
          window
        ].freeze
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
      }.freeze,
      text: {
        mode: %i[text password].freeze
      }
    }.freeze

    ENTITY_PLATFORMS = %i[alarm_control_panel
                          binary_sensor
                          button
                          camera
                          climate
                          cover
                          device_tracker
                          event
                          fan
                          humidifier
                          image
                          light
                          lawn_mower
                          lock
                          notify
                          number
                          scene
                          select
                          sensor
                          siren
                          switch
                          text
                          update
                          vacuum
                          valve
                          water_heater].freeze

    MIGRATE_DISCOVERY_JSON = { migrate_discovery: true }.to_json.freeze
  end
end

require "mqtt/home_assistant/client"
