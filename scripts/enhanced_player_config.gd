# Enhanced Player Configuration
# This file contains all the configurable parameters for the enhanced player system

class_name EnhancedPlayerConfig
extends Resource

# --- Movement Configuration ---
@export_group("Movement")
@export var move_speed: float = 3.0
@export var acceleration: float = 10.0
@export var friction: float = 12.0
@export var air_control: float = 0.3
@export var sprint_multiplier: float = 1.8
@export var crouch_speed_multiplier: float = 0.5

# --- Jump Configuration ---
@export_group("Jumping")
@export var jump_velocity: float = 4.5
@export var gravity: float = 9.8
@export var coyote_time: float = 0.1
@export var jump_buffer_time: float = 0.1

# --- Camera Configuration ---
@export_group("Camera")
@export var mouse_sensitivity: float = 0.002
@export var crouch_offset: float = -0.6

# --- Head Bobbing Configuration ---
@export_group("Head Bobbing")
@export var bob_frequency: float = 2.0
@export var bob_amplitude: float = 0.08
@export var bob_intensity: float = 0.1

# --- Stamina Configuration ---
@export_group("Stamina")
@export var max_stamina: float = 5.0
@export var stamina_depletion_rate: float = 1.0
@export var stamina_recovery_rate: float = 1.5

# --- Fear System Configuration ---
@export_group("Fear System")
@export var max_fear: float = 100.0
@export var fear_decay_rate: float = 5.0
@export var stress_breathing_threshold: float = 60.0
@export var darkness_fear_rate: float = 15.0

# --- Interaction Configuration ---
@export_group("Interaction")
@export var interaction_range: float = 2.5
@export var interaction_ray_length: float = 3.0

# --- Audio Configuration ---
@export_group("Audio")
@export var footstep_base_volume: float = -5.0
@export var breathing_base_volume: float = -20.0
@export var heartbeat_base_volume: float = -25.0
@export var crouch_volume_modifier: float = -10.0
@export var sprint_volume_modifier: float = 5.0

# --- Flashlight Configuration ---
@export_group("Flashlight")
@export var flashlight_battery_drain_rate: float = 5.0
@export var max_flashlight_battery: float = 100.0
