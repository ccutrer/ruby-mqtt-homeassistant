python/homeassistant is forked from [Home Assistant core](https://github.com/home-assistant/core), in order to have near-perfect compatibility with the Jinja templates and configuration validation.
It was forked from the the 2025.11.3 release of Home Assistant.

The following alterations have been made:

- Code not specifically used by this binding has been stripped out.
- ciso8601 is not included, since it has a native extension. Instead, the stdlib parser is used.
- All asynchronous processing has been removed; the Java side threading model dominates.
- The `hass` variable has been removed from templates; Limited templates (which are what MQTT integrations use) set it to `None` anyway.
- Limited and strict template options have been removed; it's assumed that templates are limited and not strict.

Note that this "stripped down" Home Assistant code is mostly shared with https://github.com/openhab/openhab-addons/tree/main/bundles/org.openhab.binding.homeassistant.