extends Node

# Global events autoload script
# This script handles global event signaling across the game

# Define signals for global events
signal player_died
signal player_damaged(damage_amount)
signal player_healed(heal_amount)
signal level_completed
signal game_paused
signal game_resumed
signal interaction_started
signal interaction_ended
signal settings_changed(settings_data)
signal crosshair_visibility_changed(visible)
signal low_stamina_warning
signal low_battery_warning
signal stamina_updated(current_stamina, max_stamina)
signal battery_updated(current_battery, max_battery)
signal health_updated(current_health, max_health)

# New enhanced signals
signal interaction_available(interaction_text)
signal interaction_cleared
signal fear_level_changed(fear_level)
signal player_stress_changed(stress_level)

# Battery pickup signals
signal battery_pickup_collected(charge_amount)
signal show_pickup_message(message_text)

# Settings navigation signals
signal settings_back_to_pause

# Menu state signals
signal menu_opened
signal menu_closed

# You can add more signals and event handling functions here as needed
