# Glair

A 3D first-person horror game built with Godot 4.4, featuring advanced survival mechanics and atmospheric horror elements.

## 🎮 About

Glair### Atmospheric Features
- **Dynamic Fog**: Volumetric fog environment centered on player position with realistic 3D forest backdrop
- **Realistic Lighting**: Moonlight beams, environmental glow, and flashlight illumination
- **Camera Effects**: Head bobbing, breathing-induced shake, and fear-based instability
- **3D Audio**: Spatial audio system with distance-based sound attenuationn immersive first-person horror experience that combines atmospheric tension with realistic survival mechanics. Players must navigate through dark, terrifying environments while managing limited resources and facing unknown threats. The game emphasizes psychological horror through strategic use of lighting, sound, and resource scarcity, with a robust battery collection system to keep your flashlight powered.

## ✨ Features

### 🔦 Advanced Flashlight System
- **Realistic 3D Flashlight Model** - Detailed flashlight with lens, body, grip, and power button
- **Dynamic Battery System** - Battery drains at 5 units per second when active
- **Visual Battery Feedback** - Power button glows green when on, red when off
- **Low Battery Effects** - Flickering light and reduced intensity when battery is low
- **Volumetric Fog Lighting** - Atmospheric light beams through fog environment

### 🔋 Battery Collection & Management
- **Collectible Batteries** - Find battery pickups scattered throughout the environment
- **Smart Spawning System** - Batteries spawn intelligently near walls and corners
- **Multiple Battery Types** - Different charge amounts (15%, 25%, 35%, 50%)
- **Dynamic Respawn** - Batteries respawn in different zones after collection
- **Visual Feedback** - Glowing batteries with hover effects and pickup notifications

### 🏃 Enhanced Movement System
- **Realistic Physics** - Advanced character controller with coyote time and jump buffering
- **Stamina Management** - Sprint drains stamina, affects breathing and movement
- **Dynamic Camera Effects** - Head bobbing, breathing intensity, and fear-based camera shake
- **Crouching Mechanics** - Reduced movement speed and audio for stealth
- **Audio Feedback** - Footsteps, breathing, and heartbeat audio system

### 🌲 3D Environmental Assets
- **Realistic Pine Forest** - Four distinct 3D pine tree models for varied forest atmosphere
- **Pine Model Variants** - Dense, natural, sparse, and tall pine trees with unique characteristics
- **Optimized 3D Models** - GLB format models with proper scaling and collision detection
- **Environmental Immersion** - Transition from procedural to hand-crafted 3D forest environments
- **Atmospheric Integration** - Trees interact naturally with fog and lighting systems

### 😰 Fear & Stress System
- **Dynamic Fear Level** - Increases in darkness, decreases with light
- **Breathing Intensity** - Affects camera stability and audio
- **Stress-Based Effects** - Camera shake and movement impairment when stressed
- **Environmental Response** - Fear level affects player's physical state

### 🎭 Horror Atmosphere
- **Fog Environment** - Dynamic fog system centered on player
- **Atmospheric Lighting** - Moonlight beams and eerie environmental glow
- **3D Spatial Audio** - Immersive audio system with distance-based effects
- **UI Integration** - Horror-themed UI with battery and stamina indicators

## 🎯 Controls

| Action | Key | Horror Context |
|--------|-----|----------------|
| Move Forward | W | Advance into the unknown |
| Move Backward | S | Retreat from threats |
| Move Left | A | Sidestep dangers |
| Move Right | D | Navigate around obstacles |
| Jump | Space | Escape over barriers |
| Sprint | Shift | **Run for your life** (drains stamina) |
| Crouch | Ctrl | **Hide and move silently** |
| Toggle Flashlight | F | **Illuminate or conserve battery** |
| Interact | E | **Collect batteries and investigate objects** |
| Pause Menu | Escape | Take a breath in safety |

## 🛠️ Technical Details

- **Engine**: Godot 4.4
- **Genre**: First-Person Horror/Survival
- **Platform**: Cross-platform (Windows, macOS, Linux)
- **Rendering**: Forward Plus renderer (optimized for atmospheric lighting)
- **3D Assets**: GLB format models with optimized meshes and collision shapes for environmental immersion
- **Architecture**: Component-based with global event system
- **Audio**: 3D spatial audio for immersive horror experience

## 📁 Project Structure

```
glair/
├── assets/                   # Game assets and 3D models
│   └── models/              # 3D model assets
│       └── trees/           # Pine tree model variants
│           ├── pine_dense.glb    # Dense foliage pine model
│           ├── pine_natural.glb  # Natural growth pine model
│           ├── pine_sparse.glb   # Sparse foliage pine model
│           └── pine_tall.glb     # Tall variant pine model
├── scenes/                    # Game scenes (.tscn files)
│   ├── main_menu.tscn        # Main menu interface
│   ├── map1.tscn             # Primary horror environment
│   ├── pause_menu.tscn       # In-game pause menu
│   ├── player_ui.tscn        # HUD with stamina/battery indicators
│   ├── player.tscn           # Player controller with advanced systems
│   ├── settings.tscn         # Settings configuration menu
│   ├── battery_pickup.tscn   # Collectible battery items
│   ├── battery_spawner.tscn  # Battery spawning system
│   ├── map_wide_battery_spawner.tscn  # Large-scale battery distribution
│   └── interaction_ui.tscn   # Interaction prompt system
├── scripts/                  # Game logic (.gd files)
│   ├── events.gd            # Global event system with signals
│   ├── player.gd            # Advanced player controller with fear system
│   ├── horror_ui.gd         # UI management with horror theming
│   ├── battery_pickup.gd    # Battery collection mechanics
│   ├── battery_spawner.gd   # Intelligent battery spawning system
│   ├── flashlight_config.gd # Flashlight appearance configuration
│   ├── enhanced_player_config.gd  # Player system configuration
│   ├── interaction_ui.gd    # Interaction system interface
│   ├── main_menu.gd         # Main menu navigation
│   ├── pause_menu.gd        # Pause menu functionality
│   └── settings.gd          # Settings management
├── themes/                  # UI and material themes
│   ├── flashlight_materials.tres  # Flashlight visual materials
│   └── horror_ui_theme.tres      # Horror-themed UI styling
├── textures/                # Game textures and materials
├── audio/                   # Sound effects and music
└── project.godot           # Godot project configuration
```

## 🚀 Getting Started

### Prerequisites
- Godot Engine 4.4 or later
- Git (for cloning the repository)
- **Headphones recommended** for the full horror experience

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/joshuanathanjavier/Glair.git
   ```
2. Open Godot Engine 4.4 or later
3. Click "Import" and select the project folder
4. Open `project.godot`
5. **Recommended**: Use headphones for the full horror audio experience

### Running the Game
1. Press F5 or click the play button in Godot
2. Select the main scene when prompted (`scenes/main_menu.tscn`)
3. **Adjust your audio settings** - spatial audio is crucial for immersion
4. Navigate to Map1 from the main menu to begin the horror experience

⚠️ **Content Warning**: This game contains horror elements including darkness, tension, and potentially frightening scenarios.

## 🎲 Game Mechanics

### Battery Management
- **Flashlight Battery**: Drains at 5 units per second when active
- **Battery Collection**: Find batteries with 15%, 25%, 35%, or 50% charge
- **Smart Spawning**: Batteries appear near walls, corners, and realistic locations
- **Respawn System**: New batteries appear in different zones after collection
- **Visual Indicators**: Power button changes color, lens emission varies with charge

### Survival Systems
- **Stamina System**: Sprint drains stamina, affects breathing and movement stability
- **Fear Mechanics**: Darkness increases fear level, light reduces it
- **Audio Feedback**: Footsteps, breathing intensity, and heartbeat respond to player state
- **Environmental Interaction**: Use 'E' to collect batteries and interact with objects

### Atmospheric Features
- **Dynamic Fog**: Volumetric fog environment centered on player position
- **Realistic Lighting**: Moonlight beams, environmental glow, and flashlight illumination
- **Camera Effects**: Head bobbing, breathing-induced shake, and fear-based instability
- **3D Audio**: Spatial audio system with distance-based sound attenuation

## 🔧 Development

### Current Status
🚧 **In Active Development** - This project is actively being developed with sophisticated horror mechanics and advanced systems.

### Implemented Systems
- ✅ **Advanced Player Controller** - Complete movement system with physics and audio
- ✅ **Flashlight System** - 3D model, battery management, and visual effects
- ✅ **Battery Collection** - Smart spawning, pickup mechanics, and UI integration
- ✅ **Fear & Stress System** - Dynamic fear level affecting player state
- ✅ **Audio System** - Footsteps, breathing, heartbeat with 3D spatial audio
- ✅ **UI Framework** - Horror-themed interface with real-time status updates
- ✅ **Event System** - Global signal management for game communication
- ✅ **Settings System** - Configurable audio, visual, and control options
- ✅ **Fog Environment** - Atmospheric fog system with volumetric lighting
- ✅ **3D Environmental Assets** - Realistic pine forest with four distinct tree model variants

### Technical Architecture
- **Events System**: Global event handling through `events.gd` autoload for horror triggers and UI updates
- **Player Controller**: Sophisticated first-person movement with survival mechanics in `player.gd`
- **Resource Management**: Battery and stamina systems with intelligent spawning and collection
- **UI Management**: Component-based UI system with real-time status indicators
- **Scene Management**: Modular scene structure for different horror environments
- **Configuration System**: Resource-based configuration for easy tweaking of game parameters

### Contributing
This appears to be a personal project. If you'd like to contribute:
1. Fork the repository
2. Create a feature branch
3. Submit pull requests with clear descriptions
4. Follow the existing code structure and commenting conventions

## 📋 Roadmap

### Upcoming Features
- [ ] **Enemy/Threat AI** - Implement dynamic horror encounters and creature behavior
- [ ] **Enhanced Audio** - Add more horror sound effects and dynamic ambient audio
- [ ] **Additional Environments** - Expand beyond the pine forest with more diverse terrifying locations
- [ ] **Narrative Elements** - Develop story progression and environmental storytelling
- [ ] **Inventory System** - Expand beyond batteries to include key items and tools
- [ ] **Multiple Endings** - Add branching story paths based on player choices
- [ ] **Save System** - Implement game state persistence
- [ ] **Accessibility Options** - Add comfort settings for different horror tolerance levels

### Performance & Polish
- [ ] **Performance Optimization** - Optimize lighting and fog systems for smooth gameplay
- [ ] **Visual Polish** - Enhance materials, textures, and lighting effects
- [ ] **Audio Polish** - Refine 3D audio positioning and environmental sound design
- [ ] **UI Improvements** - Add more visual feedback and polish to interface elements

## 🐛 Known Issues

As this project is in development, please check the Issues tab for current bugs and planned features.

## 📄 License

This project's license is not specified. Please contact the repository owner for licensing information.

## 👨‍💻 Author

**Joshua Nathan Javier** - [GitHub Profile](https://github.com/joshuanathanjavier)

---

*Enter the darkness... if you dare. Built with ❤️ and 😱 using Godot Engine*