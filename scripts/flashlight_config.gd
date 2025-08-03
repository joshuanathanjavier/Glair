# Flashlight Style Configuration
# This file contains styling parameters for the flashlight model

class_name FlashlightConfig
extends Resource

# --- Visual Appearance ---
@export var body_color: Color = Color(0.15, 0.15, 0.15, 1)
@export var body_metallic: float = 0.8
@export var body_roughness: float = 0.25

@export var lens_color: Color = Color(0.95, 0.95, 0.95, 0.9)
@export var lens_emission_color: Color = Color(1, 0.964706, 0.819608, 1)
@export var lens_emission_strength: float = 0.5

@export var grip_color: Color = Color(0.05, 0.05, 0.05, 1)
@export var grip_roughness: float = 0.8

@export var button_on_color: Color = Color(0.2, 0.8, 0.2, 1)
@export var button_off_color: Color = Color(0.8, 0.2, 0.2, 1)

# --- Lighting Parameters ---
@export var max_light_energy: float = 5.0
@export var low_battery_threshold: float = 0.2
@export var flicker_frequency: float = 0.02
@export var flicker_intensity: float = 0.1

# --- Size Parameters ---
@export var body_top_radius: float = 0.15
@export var body_bottom_radius: float = 0.12
@export var body_height: float = 0.8

@export var lens_radius: float = 0.16
@export var lens_height: float = 0.05

@export var grip_radius: float = 0.13
@export var grip_height: float = 0.3

@export var button_radius: float = 0.02
@export var button_height: float = 0.015
