# Input Setup Helper
# This script helps set up the required input actions for the battery pickup system

# Add this to your project's input map:
# Action Name: "interact"
# Default Key: E
# This is used for picking up batteries and other interactions

# You can add this programmatically with:

func setup_input_map():
	if not InputMap.has_action("interact"):
		InputMap.add_action("interact")
		var event = InputEventKey.new()
		event.keycode = KEY_E
		InputMap.action_add_event("interact", event)
		print("Added 'interact' action to input map with E key")
	else:
		print("'interact' action already exists in input map")

# Call this function in your main scene or autoload to ensure the input is set up
