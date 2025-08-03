extends Node

# Global events autoload script
# This script handles global event signaling across the game

# Define signals for global events
signal player_died
signal level_completed
signal game_paused
signal game_resumed
signal interaction_started
signal interaction_ended
signal settings_changed(settings_data)
signal low_stamina_warning
signal low_battery_warning
signal stamina_updated(current_stamina, max_stamina)
signal battery_updated(current_battery, max_battery)

# You can add more signals and event handling functions here as needed
