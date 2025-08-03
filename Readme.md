# Glair

A 3D first-person horror game built with Godot 4.4.

## 🎮 About

Glair is an immersive first-person horror experience that combines atmospheric tension with realistic survival mechanics. Players must navigate through dark, terrifying environments while managing limited resources and facing unknown threats. The game emphasizes psychological horror through strategic use of lighting, sound, and resource scarcity.

## ✨ Features

### Survival Horror Mechanics
- **Limited Visibility** - Navigate through dark environments
- **Resource Management** - Conserve stamina and flashlight battery
- **Stealth Elements** - Crouch to avoid detection
- **Atmospheric Tension** - Immersive horror experience

### Movement System
- **WASD Movement** - Silent or loud movement affects stealth
- **Sprint System** - Escape threats but drains stamina quickly
- **Crouching** - Move quietly to avoid attracting attention
- **Jumping** - Navigate obstacles while fleeing
- **Mouse Look** - Smooth camera control for scanning threats

### Interactive Elements
- **Flashlight** - Essential light source with limited battery life
- **Interaction System** - Investigate objects and clues
- **Pause Menu** - Safe space to catch your breath
- **Settings Menu** - Adjust audio and visual settings for optimal horror experience

### Horror Elements
- **Stamina System** - Panic and exhaustion affect your ability to escape
- **Flashlight Battery** - Darkness is your enemy - manage your light carefully
- **Sound Design** - Audio cues are crucial for survival
- **Atmospheric Lighting** - Limited visibility creates constant tension

## 🎯 Controls

| Action | Key | Horror Context |
|--------|-----|----------------|
| Move Forward | W | Advance into the unknown |
| Move Backward | S | Retreat from threats |
| Move Left | A | Sidestep dangers |
| Move Right | D | Navigate around obstacles |
| Jump | Space | Escape over barriers |
| Sprint | Shift | **Run for your life** |
| Crouch | Ctrl | **Hide and move silently** |
| Toggle Flashlight | F | **Illuminate or conserve battery** |
| Interact | E | Investigate objects and clues |
| Pause Menu | Escape | Take a breath in safety |

## 🛠️ Technical Details

- **Engine**: Godot 4.4
- **Genre**: First-Person Horror/Survival
- **Platform**: Cross-platform (Windows, macOS, Linux)
- **Rendering**: Forward Plus renderer (optimized for atmospheric lighting)
- **Architecture**: Component-based with global event system
- **Audio**: 3D spatial audio for immersive horror experience

## 📁 Project Structure

```
glair/
├── scenes/          # Game scenes (.tscn files)
│   ├── main_menu.tscn
│   ├── map1.tscn
│   ├── pause_menu.tscn
│   ├── player_ui.tscn
│   ├── player.tscn
│   └── settings.tscn
├── scripts/         # Game logic (.gd files)
│   ├── events.gd    # Global event system
│   ├── player.gd    # Player controller
│   ├── main_menu.gd
│   ├── pause_menu.gd
│   └── settings.gd
├── textures/        # Game textures and materials
├── audio/           # Sound effects and music
└── project.godot    # Godot project configuration
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
2. Open Godot Engine
3. Click "Import" and select the project folder
4. Open `project.godot`

### Running the Game
1. Press F5 or click the play button in Godot
2. Select the main scene when prompted
3. **Adjust your audio settings** - sound is crucial for survival
4. The game will start at the main menu

⚠️ **Warning**: This game contains horror elements including darkness, tension, and potentially frightening scenarios.

## 🔧 Development

### Current Status
🚧 **In Active Development** - This project is currently being developed and features are being added regularly.

### Contributing
This appears to be a personal project. If you'd like to contribute, please fork the repository and submit pull requests.

### Code Architecture
- **Events System**: Global event handling through `events.gd` autoload for horror triggers
- **Player Controller**: First-person movement with survival mechanics in `player.gd`
- **UI Management**: Separate scripts for menu systems and HUD elements
- **Scene Management**: Modular scene structure for different horror environments
- **Resource Management**: Stamina and battery systems create tension and strategic gameplay

## 📋 Roadmap

- [ ] Complete horror atmosphere and lighting system
- [ ] Implement enemy/threat AI and encounters
- [ ] Add horror sound effects and ambient audio
- [ ] Create additional terrifying levels/environments
- [ ] Develop narrative elements and story progression
- [ ] Add inventory system for key items
- [ ] Implement multiple endings based on player choices
- [ ] Optimize performance for smooth horror experience
- [ ] Add accessibility options for different comfort levels

## 🐛 Known Issues

As this project is in development, please check the Issues tab for current bugs and planned features.

## 📄 License

This project's license is not specified. Please contact the repository owner for licensing information.

## 👨‍💻 Author

**Joshua Nathan Javier** - [GitHub Profile](https://github.com/joshuanathanjavier)

---

*Enter the darkness... if you dare. Built with ❤️ and 😱 using Godot Engine*