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

# Key collection signals
signal key_collected

# Player escape signals
signal player_escaped

# Settings navigation signals
signal settings_back_to_pause

# Menu state signals
signal menu_opened
signal menu_closed

# Objective system signals
signal objective_added(title: String, description: String)
signal objective_completed(title: String, reward_message: String)
signal objective_failed(title: String)
signal objective_revealed(title: String, description: String)
signal objective_progress_updated(title: String, current: float, target: float)
signal objectives_updated(objectives: Array)

# Enhanced monster AI signals
signal player_movement_detected(position: Vector3, intensity: float)
signal flashlight_toggled(is_on: bool)
signal player_interaction_started(interaction_type: String)
signal player_escaped_from_monster  # New signal for successful escape
signal random_spawning_complete  # Signal when random spawning is finished

# You can add more signals and event handling functions here as needed
