# frozen_string_literal: true

require_relative "lib/mqtt/home_assistant/version"

Gem::Specification.new do |s|
  s.name = "mqtt-homeassistant"
  s.version = MQTT::HomeAssistant::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ["Cody Cutrer"]
  s.email = "cody@cutrer.com'"
  s.homepage = "https://github.com/ccutrer/ruby-mqtt-homeassistant"
  s.summary = "Library for publishing device auto-discovery configuration for Home Assistant via MQTT."
  s.license = "MIT"
  s.metadata = {
    "rubygems_mfa_required" => "true"
  }

  s.files = Dir["{lib}/**/*"]

  s.required_ruby_version = ">= 3.2"

  s.add_dependency "json", "~> 2.0"
  s.add_dependency "mqtt-ccutrer", "~> 1.0", ">= 1.0.3"
end
