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

# You can add more signals and event handling functions here as needed
