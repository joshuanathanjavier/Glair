# Glair

A 3D first-person horror game built with Godot 4.4, featuring advanced survival mechanics and atmospheric horror elements.

*Last updated: August 2025*

## 🎮 About

Glair is an immersive first-person horror experience that combines atmospheric tension with realistic survival mechanics. Players must navigate through dark, terrifying environments while managing limited resources and facing unknown threats. The game emphasizes psychological horror through strategic use of lighting, sound, and resource scarcity, with a robust battery collection system to keep your flashlight powered. Face intelligent AI enemies that hunt you through the fog-covered forest, where survival depends on your ability to manage fear, health, and resources while avoiding or confronting deadly creatures.

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
- **Smart Footstep System** - Footsteps only play when actively pressing movement keys (WASD)

### 🌲 3D Environmental Assets
- **Realistic Pine Forest** - Four distinct 3D pine tree models for varied forest atmosphere
- **Pine Model Variants** - Dense, natural, sparse, and tall pine trees with unique characteristics
- **Ground Vegetation** - Realistic grass models for enhanced environmental detail
- **Optimized 3D Models** - GLB format models with proper scaling and collision detection
- **Environmental Immersion** - Transition from procedural to hand-crafted 3D forest environments
- **Atmospheric Integration** - Trees and vegetation interact naturally with fog and lighting systems

### 😰 Fear & Stress System
- **Dynamic Fear Level** - Increases in darkness, decreases with light
- **Breathing Intensity** - Affects camera stability and audio
- **Stress-Based Effects** - Camera shake and movement impairment when stressed
- **Environmental Response** - Fear level affects player's physical state

### 🔑 Keys & Objective System
- **Key Collection** - 10 keys spawn across multiple zones; pick them up to progress your main objective
- **Objective Tracking** - Active, optional, and hidden objectives with progress updates and rewards
- **Escape Objective** - After meeting key objectives, find the glowing exit to escape the forest
- **Dynamic Progress Display** - Real-time key collection progress with dynamic count updates

### 💀 Enhanced Enemy AI & Threats
- **Intelligent Monster AI** - Advanced enemy with multiple behavioral states (idle, patrol, chase, attack, investigating, stalking, alerted)
- **Random Spawning System** - 5 monsters spawn across 3 zones with intelligent placement near trees and hidden spots
- **Enhanced Detection System** - Monsters detect players through line of sight, sound, and environmental awareness
- **Stealth Mechanics** - Crouching reduces visibility by 80%, flashlight off reduces visibility by 60%
- **Memory System** - Monsters remember last known player position and investigate areas
- **Patrol Behavior** - Enemies patrol predefined routes when not engaged
- **Combat System** - Monsters can deal damage and increase player fear levels
- **Fear Integration** - Enemy encounters dramatically increase stress and breathing intensity
- **Escape Mechanics** - Player feedback when successfully escaping from monsters
- **Audio Feedback** - Monster growls when chasing, stalking, or attacking players

### 💖 Health & Survival System
- **Health Management** - Player health system with damage from enemy attacks
- **Health Regeneration** - Slow automatic healing when not at maximum health
- **Death & Game Over** - Complete death system with game over screen and restart options
- **Damage Feedback** - Visual screen flash effects and fear increase when taking damage
- **Survival Mechanics** - Health, stamina, and battery management are crucial for survival

### 🎭 Horror Atmosphere
- **Fog Environment** - Dynamic fog system centered on player
- **Atmospheric Lighting** - Moonlight beams and eerie environmental glow
- **3D Spatial Audio** - Immersive audio system with distance-based effects
- **UI Integration** - Horror-themed UI with battery and stamina indicators
- **Comprehensive Audio System** - Dynamic footstep, breathing, heartbeat, and ambient horror sounds

### 🧰 HUD & UI Enhancements
- **Status Bars** - Stamina, Health, Battery with warning states (20%, 30%, 25% thresholds)
- **Interaction Prompts** - Contextual "Press E" prompts and animated pickup messages
- **Crosshair Toggle** - Visibility preference persisted via settings storage
- **Game Start Notification** - Displays main objective with fade animations on game start

### ⏸️ Pause & Settings Flow
- **Overlay Settings** - Open Settings from Pause without leaving the current scene
- **Menu-Aware UI** - HUD and prompts auto-hide when menus are open

## 🎯 Controls

| Action | Key | Horror Context |
|--------|-----|----------------|
| Move Forward | W | Advance into the unknown |
| Move Backward | S | Retreat from threats |
| Move Left | A | Sidestep dangers |
| Move Right | D | Navigate around obstacles |
| Jump | Space | Escape over barriers |
| Sprint | Shift | **Run for your life** (drains stamina) |
| Crouch | Ctrl | **Hide and move silently** (reduces visibility by 80%) |
| Toggle Flashlight | F | **Illuminate or conserve battery** |
| Interact | E | **Collect items, interact with objects, and use the exit door** |
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
│       ├── character/       # Character and creature models
│       │   ├── creepy_monster.glb    # AI enemy 3D model with animations
│       │   ├── creepy_monster_0.jpg  # Monster texture variant 1
│       │   ├── creepy_monster_1.png  # Monster texture variant 2
│       │   └── creepy_monster_2.png  # Monster texture variant 3
│       ├── grass/           # Ground vegetation models
│       │   ├── grass.glb         # Realistic grass model for environment
│       │   └── grass_Image_0.png # Grass texture and material
│       └── trees/           # Pine tree model variants
│           ├── pine_dense.glb    # Dense foliage pine model
│           ├── pine_natural.glb  # Natural growth pine model
│           ├── pine_sparse.glb   # Sparse foliage pine model
│           └── pine_tall.glb     # Tall variant pine model
├── scenes/                    # Game scenes (.tscn files)
│   ├── main_menu.tscn        # Main menu interface
│   ├── map1.tscn             # Primary horror environment
│   ├── pause_menu.tscn       # In-game pause menu
│   ├── game_over.tscn        # Game over screen with restart options
│   ├── game_start_notification.tscn  # Game start objective display
│   ├── player_ui.tscn        # HUD with stamina/battery indicators
│   ├── player.tscn           # Player controller with advanced systems
│   ├── settings.tscn         # Settings configuration menu
│   ├── creepy_monster.tscn   # AI enemy with intelligent behavior
│   ├── monster_spawner.tscn  # Random monster spawning system
│   ├── battery_pickup.tscn   # Collectible battery items
│   ├── battery_spawner.tscn  # Battery spawning system
│   ├── map_wide_battery_spawner.tscn  # Large-scale battery distribution
│   ├── interaction_ui.tscn   # Interaction prompt system
│   ├── exit_door.tscn        # Escape door (glowing, interact to exit)
│   ├── game_completed.tscn   # Post-escape completion scene
│   ├── key_pickup.tscn       # Collectible key item
│   ├── key_spawner.tscn      # Spawns keys across zones
│   ├── objective_ui.tscn     # Displays objectives and progress
│   ├── coordinate_display.tscn  # Developer/utility display
│   └── door_spawner.tscn     # Spawns exit door(s)
├── scripts/                  # Game logic (.gd files)
│   ├── events.gd            # Global event system with signals
│   ├── player.gd            # Advanced player controller with fear system
│   ├── creepy_monster.gd    # Enhanced AI enemy with stealth mechanics
│   ├── monster_spawner.gd   # Random monster spawning with zone management
│   ├── game_start_notification.gd  # Game start objective display
│   ├── game_over.gd         # Game over screen management
│   ├── horror_ui.gd         # UI management with horror theming
│   ├── battery_pickup.gd    # Battery collection mechanics
│   ├── battery_spawner.gd   # Intelligent battery spawning system
│   ├── objective_manager.gd # Objective tracking and progress
│   ├── exit_door.gd         # Exit interaction and scene transition
│   ├── key_pickup.gd        # Enhanced key pickup with dynamic progress
│   ├── key_spawner.gd       # Key spawning logic
│   ├── coordinate_display.gd  # Coordinate/utility display
│   ├── door_spawner.gd      # Exit door spawner
│   ├── flashlight_config.gd # Flashlight appearance configuration
│   ├── enhanced_player_config.gd  # Player system configuration
│   ├── interaction_ui.gd    # Interaction system interface
│   ├── main_menu.gd         # Main menu navigation
│   ├── pause_menu.gd        # Pause menu functionality
│   ├── settings.gd          # Settings management
│   ├── ambient_audio_manager.gd      # Ambient horror sound management
│   ├── distant_footsteps_manager.gd  # Distant footstep atmosphere system
│   └── random_monster_growls.gd      # Random monster growl atmosphere
├── themes/                  # UI and material themes
│   ├── flashlight_materials.tres  # Flashlight visual materials
│   └── horror_ui_theme.tres      # Horror-themed UI styling
├── default_bus_layout.tres  # Audio bus configuration for mixing
├── textures/                # Game textures and materials
├── audio/                   # Sound effects and music
│   ├── footsteps_grass.wav      # Player movement footstep sounds
│   ├── heavy_breathing.wav      # Stress-based breathing audio
│   ├── heartbeat.wav            # Fear-induced heartbeat sounds
│   ├── flashlight_click.wav     # Flashlight toggle audio feedback
│   ├── pickup_sound.wav         # Item collection sound effects
│   ├── forest_ambient.wav       # Continuous forest background ambience
│   ├── owls_hoot.wav            # Atmospheric owl hooting sounds
│   ├── wolf_howl.wav            # Distant wolf howling effects
│   ├── horror_ambient.ogg       # Eerie horror atmosphere audio
│   └── monster_growl.wav        # Enemy monster vocalizations
└── project.godot           # Godot project configuration
```

## 🚀 Getting Started

### Prerequisites
- Godot Engine 4.4 or later
- Git (for cloning the repository)
- **Headphones required** for the full horror audio experience

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
3. **Use headphones** - 3D spatial audio is essential for the horror experience
4. Navigate to Map1 from the main menu to begin the horror experience
5. **Audio Controls**: Master volume affects all sounds, individual bus volumes for fine-tuning

⚠️ **Content Warning**: This game contains horror elements including darkness, tension, potentially frightening scenarios, and hostile AI enemies that actively hunt and attack the player.

## 🎲 Game Mechanics

### Battery Management
- **Flashlight Battery**: Drains at 5 units per second when active
- **Battery Collection**: Find batteries with 15%, 25%, 35%, or 50% charge
- **Smart Spawning**: Batteries appear near walls, corners, and realistic locations
- **Respawn System**: New batteries appear in different zones after collection
- **Visual Indicators**: Power button changes color, lens emission varies with charge
- **Respawn System**: New batteries can appear after pickups with in-world hint messaging
- **HUD Warnings**: Battery bar enters warning state below 25%

### Survival Systems
- **Stamina System**: Sprint drains stamina, affects breathing and movement stability
- **Fear Mechanics**: Darkness increases fear level, light reduces it; enemy encounters spike fear
- **Health System**: Take damage from monster attacks, regenerate health slowly over time
- **Audio Feedback**: Dynamic footsteps, breathing intensity, and heartbeat respond to player state
- **Environmental Interaction**: Use 'E' to collect batteries and interact with objects
- **Death System**: Die when health reaches zero, with game over screen and restart options

### Enhanced Stealth Mechanics
- **Crouching Stealth**: Crouching reduces monster visibility by 80% and sound by 70%
- **Flashlight Management**: Keeping flashlight off reduces monster visibility by 60%
- **Environmental Awareness**: Monsters use line of sight, sound detection, and environmental factors
- **Memory System**: Monsters remember last known player position and investigate areas
- **Escape Opportunities**: Easier to escape when using stealth mechanics effectively

### Atmospheric Features
- **Dynamic Fog**: Volumetric fog environment centered on player position with realistic 3D forest backdrop
- **Realistic Lighting**: Moonlight beams, environmental glow, and flashlight illumination
- **Enhanced Environment**: Detailed forest with pine trees and realistic grass vegetation
- **Camera Effects**: Head bobbing, breathing-induced shake, and fear-based instability
- **3D Audio**: Spatial audio system with distance-based sound attenuation and organized bus mixing
- **Enhanced Monster Encounters**: Intelligent AI enemies with multiple behavioral states
- **Ambient Horror Audio**: Random owl hoots, wolf howls, distant footsteps, and horror atmosphere
- **Monster Audio**: Enemy vocalizations that respond to AI behavior states

### Keys and Escape
- **Collect 10 Keys**: Keys are distributed across multiple zones; track progress via the objectives UI
- **Find the Exit**: Locate the glowing door and press Interact to escape
- **Dynamic Progress**: Real-time updates show current key collection progress

### Objectives
- **Active Objectives**: Main tasks such as collecting keys
- **Optional Challenges**: Time-based survival goals (e.g., 2 minutes, 5 minutes)
- **Hidden Objectives**: Reveal as you progress, with reward messages on completion
- **Game Start Notification**: Clear objective display when starting the game

## 🔧 Development

### Recent Updates (August 2025)
- ✅ **Enhanced Monster AI** - Random spawning system with 5 monsters across 3 zones
- ✅ **Stealth Mechanics** - Crouching and flashlight management affect monster detection
- ✅ **Advanced AI States** - New investigating, stalking, and alerted behaviors
- ✅ **Memory System** - Monsters remember and investigate last known player positions
- ✅ **Game Start Notification** - Objective display with fade animations
- ✅ **Dynamic Key Progress** - Real-time key collection progress updates
- ✅ **Enhanced Spawning** - Intelligent monster placement near trees and hidden spots
- ✅ **Comprehensive Audio System** - Complete horror audio implementation with dynamic footstep, breathing, heartbeat, and ambient sounds
- ✅ **Audio Bus Configuration** - Professional audio mixing with organized bus layout
- ✅ **Smart Footstep System** - Footsteps only trigger on active movement input

### Current Status
🚧 **In Active Development** - This project is actively being developed with sophisticated horror mechanics and advanced systems.

### Implemented Systems
- ✅ **Advanced Player Controller** - Complete movement system with physics and audio
- ✅ **Flashlight System** - 3D model, battery management, and visual effects
- ✅ **Battery Collection** - Smart spawning, pickup mechanics, and UI integration
- ✅ **Fear & Stress System** - Dynamic fear level affecting player state
- ✅ **Audio System** - Dynamic footstep, breathing, heartbeat, and ambient horror sounds with 3D spatial audio
- ✅ **UI Framework** - Horror-themed interface with real-time status updates
- ✅ **Event System** - Global signal management for game communication
- ✅ **Settings System** - Configurable audio, visual, and control options
- ✅ **Fog Environment** - Atmospheric fog system with volumetric lighting
- ✅ **3D Environmental Assets** - Realistic pine forest with four distinct tree model variants and ground vegetation
- ✅ **Enhanced Enemy AI System** - Intelligent monsters with random spawning, stealth mechanics, and multiple behavioral states
- ✅ **Health & Damage System** - Player health, enemy damage, and regeneration mechanics
- ✅ **Game Over System** - Complete death handling with restart functionality
- ✅ **Objective System** - Active, optional, and hidden objectives with progress tracking
- ✅ **Key Collection & Spawner** - Multi-zone key distribution with dynamic progress
- ✅ **Exit Door & Game Completion Flow** - Escape mechanics with completion scene
- ✅ **Game Start Notification** - Objective display system with animations

### Technical Architecture
- **Events System**: Global event handling through `events.gd` autoload for horror triggers and UI updates
- **Player Controller**: Sophisticated first-person movement with survival mechanics in `player.gd`
- **Resource Management**: Battery and stamina systems with intelligent spawning and collection
- **UI Management**: Component-based UI system with real-time status indicators
- **Scene Management**: Modular scene structure for different horror environments
- **Configuration System**: Resource-based configuration for easy tweaking of game parameters
- **Objective Manager**: Centralized objective tracking and events
- **Key Spawner**: Multi-zone key distribution with placement heuristics
- **Exit Door**: Interact-to-escape flow integrated with global events
- **Monster Spawner**: Random spawning system with intelligent zone management and placement
- **Enhanced AI**: Multiple behavioral states with stealth mechanics and memory system

### Contributing
This appears to be a personal project. If you'd like to contribute:
1. Fork the repository
2. Create a feature branch
3. Submit pull requests with clear descriptions
4. Follow the existing code structure and commenting conventions

## 📋 Roadmap

### Upcoming Features
- [ ] **Additional Enemy Types** - Expand beyond the current monster with different AI patterns
- [ ] **Additional Environments** - Expand beyond the pine forest with more diverse terrifying locations
- [ ] **Narrative Elements** - Develop story progression and environmental storytelling
- [ ] **Inventory System** - Expand beyond batteries to include key items and tools
- [ ] **Multiple Endings** - Add branching story paths based on player choices
- [ ] **Save System** - Implement game state persistence
- [ ] **Accessibility Options** - Add comfort settings for different horror tolerance levels

### Performance & Polish
- [ ] **Performance Optimization** - Optimize lighting and fog systems for smooth gameplay
- [ ] **Visual Polish** - Enhance materials, textures, and lighting effects
- [ ] **UI Improvements** - Add more visual feedback and polish to interface elements

## 🐛 Known Issues

As this project is in development, please check the Issues tab for current bugs and planned features.

## 📄 License

This project's license is not specified. Please contact the repository owner for licensing information.

## 👨‍💻 Author

**Joshua Nathan Javier** - [GitHub Profile](https://github.com/joshuanathanjavier)
## 💡 Contributors
<a href="https://github.com/joshuanathanjavier/Glair/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=joshuanathanjavier/Glair" />
</a>

---

*Enter the darkness... if you dare. Built with ❤️ and 😱 using Godot Engine*

