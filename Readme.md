# Glair

A 3D first-person horror game built with Godot 4.4, featuring survival mechanics, atmospheric horror, and intelligent AI enemies.

*Last updated: August 2025*

## 🎮 About

Glair is an immersive first-person horror experience where players navigate dark, fog-covered forests while managing limited resources and facing intelligent threats. The game emphasizes psychological horror through strategic lighting, sound design, and resource scarcity.

## ✨ Features

### 🔦 Core Systems
- **Advanced Flashlight System** - 3D flashlight model with dynamic battery management (drains at 5 units/second)
- **Battery Collection** - Smart spawning system with different charge amounts (15%, 25%, 35%, 50%)
- **Enhanced Movement** - Realistic physics with stamina management, crouching, and head bobbing
- **Fear & Stress System** - Dynamic fear levels affecting breathing, camera stability, and movement

### 🌲 Environment & Atmosphere
- **3D Forest Environment** - Four distinct pine tree variants with realistic grass and vegetation
- **Dynamic Fog System** - Volumetric fog with atmospheric lighting effects
- **3D Spatial Audio** - Immersive sound system with footsteps, breathing, heartbeat, and ambient horror
- **Horror UI Theme** - Atmospheric interface with real-time status indicators

### 😰 Horror Mechanics
- **Intelligent AI Enemies** - 5 monsters with multiple behavioral states (patrol, chase, attack, investigate)
- **Stealth System** - Crouching reduces visibility by 80%, flashlight off by 60%
- **Health & Survival** - Damage system with regeneration, game over handling, and restart options
- **Objective System** - Collect 10 keys across multiple zones to unlock the exit door

## 🎯 Controls

| Action | Key | Description |
|--------|-----|-------------|
| Movement | WASD | Walk, run, and navigate |
| Jump | Space | Escape over barriers |
| Sprint | Shift | Run (drains stamina) |
| Crouch | Ctrl | Hide and move silently |
| Flashlight | F | Toggle light on/off |
| Interact | E | Collect items and interact |
| Pause | Escape | Open menu |

## 🛠️ Technical Details

- **Engine**: Godot 4.4
- **Genre**: First-Person Horror/Survival
- **Platform**: Cross-platform (Windows, macOS, Linux)
- **Rendering**: Forward Plus renderer with atmospheric lighting
- **3D Assets**: GLB format models with optimized meshes
- **Audio**: 3D spatial audio with organized bus mixing

## 📁 Project Structure

```
glair/
├── assets/                   # Game assets and 3D models
│   ├── models/              # Character, grass, and tree models
│   └── images/              # Textures and UI elements
├── scenes/                   # Game scenes (.tscn files)
│   ├── main_menu.tscn       # Main menu interface
│   ├── map1.tscn            # Primary horror environment
│   ├── player.tscn          # Player controller
│   ├── creepy_monster.tscn  # AI enemy
│   └── [other game scenes]  # UI, pickups, spawners
├── scripts/                  # Game logic (.gd files)
│   ├── events.gd            # Global event system
│   ├── player.gd            # Player controller
│   ├── creepy_monster.gd    # Enemy AI
│   └── [other game systems] # UI, audio, objectives
├── audio/                    # Sound effects and music
├── themes/                   # UI and material themes
└── project.godot            # Godot project configuration
```

## 🚀 Getting Started

### Prerequisites
- Godot Engine 4.4 or later
- Git (for cloning)
- **Headphones recommended** for full horror experience

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/joshuanathanjavier/Glair.git
   ```
2. Open Godot Engine 4.4+
3. Import the project folder
4. Open `project.godot`
5. Run the game (F5) and select `scenes/main_menu.tscn`

⚠️ **Content Warning**: Contains horror elements, darkness, tension, and hostile AI enemies.

## 🎲 Game Mechanics

### Survival Systems
- **Battery Management**: Flashlight drains battery; find pickups to recharge
- **Stamina System**: Sprinting drains stamina, affects breathing and movement
- **Health System**: Take damage from enemies, regenerate over time
- **Fear Mechanics**: Darkness increases fear, light reduces it; affects player state

### Stealth & Combat
- **Stealth Options**: Crouch to reduce visibility and sound
- **AI Behavior**: Enemies patrol, investigate sounds, and chase players
- **Escape Mechanics**: Use environment and stealth to avoid detection

### Objectives & Progression
- **Key Collection**: Find 10 keys across multiple zones
- **Exit Door**: Locate and interact with the glowing exit after collecting keys
- **Progress Tracking**: Real-time updates via objectives UI

## 🔧 Development

### Current Status
🚧 **In Active Development** - Sophisticated horror mechanics and advanced systems implemented.

### Recent Updates
- ✅ Enhanced Monster AI with random spawning across 3 zones
- ✅ Stealth mechanics (crouching, flashlight management)
- ✅ Advanced AI states (investigating, stalking, alerted)
- ✅ Memory system for enemy behavior
- ✅ Dynamic key progress tracking
- ✅ Comprehensive 3D audio system
- ✅ Smart footstep and breathing systems

### Implemented Systems
- ✅ Advanced player controller with physics and audio
- ✅ Complete flashlight and battery systems
- ✅ Fear and stress mechanics
- ✅ 3D environmental assets (forest, vegetation)
- ✅ Enhanced enemy AI with multiple behaviors
- ✅ Health, damage, and game over systems
- ✅ Objective tracking and key collection
- ✅ Horror-themed UI and audio

## 📋 Roadmap

### Upcoming Features
- [ ] Additional enemy types with different AI patterns
- [ ] More diverse environments beyond the forest
- [ ] Narrative elements and environmental storytelling
- [ ] Inventory system expansion
- [ ] Multiple endings based on player choices
- [ ] Save system for game state persistence
- [ ] Accessibility options for different horror tolerance levels

### Performance & Polish
- [ ] Lighting and fog system optimization
- [ ] Enhanced materials and visual effects
- [ ] UI improvements and visual feedback

## 🐛 Known Issues

This project is in active development. Check the Issues tab for current bugs and planned features.

## 📄 License

License information not specified. Contact the repository owner for details.

## 👨‍💻 Author

**Joshua Nathan Javier** - [GitHub Profile](https://github.com/joshuanathanjavier)

## 💡 Contributors
<a href="https://github.com/joshuanathanjavier/Glair/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=joshuanathanjavier/Glair" />
</a>

---

*Enter the darkness... if you dare. Built with ❤️ and 😱 using Godot Engine*

