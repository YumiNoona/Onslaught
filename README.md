<div align="center">

# 🔫 Onslaught

### Fight, upgrade, and survive in a relentless rogue-lite experience packed with explosive combat and endless replayability.

Survive endless waves of enemies, manage your arsenal, upgrade your abilities, and conquer the battlefield.

</div>

![Godot](https://img.shields.io/badge/Godot-4.6-blue?style=for-the-badge&logo=godotengine)
![GDScript](https://img.shields.io/badge/GDScript-2.0-blueviolet?style=for-the-badge&logo=godotengine)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Active-success?style=for-the-badge)
![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20Linux%20%7C%20macOS%20%7C%20Web-lightgrey?style=for-the-badge)

---

## 📘 Overview

**Onslaught** is a thrilling top-down action rogue-lite arcade game where the player fights progressively difficult waves of enemies using multiple weapons while managing health, movement, and positioning.

The project features a highly modular architecture, a robust data-driven weapon configuration system, and follows modern Godot 4 best practices. Whether you're looking for an arcade shooter to play or a polished open-source codebase to learn from, this project has it all.

---

## ✨ Key Features

### 🔫 Arsenal & Gunplay
- **11 Unique Weapons:** Pistols, Assault Rifles, SMGs, Shotguns, and Sniper Rifles — each with unique stats and feel.
- **Data-Driven Design:** Every weapon is a `.tres` resource file with configurable damage, fire rate, spread, ammo, pierce, and more.
- **Dynamic Spread & Recoil:** Procedural crosshair recoil and weapon spread logic varies by weapon type. SMGs spray wide, snipers stay precise.
- **Weapon Shop:** Between-wave shop system to purchase weapons using collected coins, with smart inventory that deprioritizes previously seen weapons.
- **Scene Weapon Drops:** Every 4th wave, physical weapon pickups spawn on the map for free collection.
- **Ammo & Reload:** Weapons with limited magazines require manual reloading (`R` key), displayed via an on-screen reload bar.

### 👾 Enemies & AI
- **6 Enemy Types:** Standard Mobs, fast Fliers, supportive Healers, tough Mutants, relentless Zombies, and devastating Bosses.
- **Tiered Spawning:** Early waves spawn only basic enemies; mid-game introduces tougher types; late-game throws everything at you.
- **Boss Waves:** Every 5th wave is a boss encounter with enhanced HP, speed scaling, enrage mechanics, and guaranteed coin drops.
- **Difficulty Scaling:** Enemy count, HP, and spawn speed increase every wave. Boss attack cooldowns shrink over time.
- **Loot Drops:** Enemies drop coins (magnetic attraction pickup) and power-ups (Speed, Damage, Invulnerability) on defeat.

### 🧑‍🤝‍🧑 Playable Characters

| Character | Playstyle | Ability | Pros | Cons |
|---|---|---|---|---|
| **Shooter** | Balanced all-rounder | **Adrenaline Rush** — +20% speed & fire rate for 3s (10s CD) | No weaknesses | No strengths |
| **Rocky** | Heavy-hitting tank | **Ground Slam** — AOE knockback & damage to nearby enemies (6s CD) | +50% HP, damage resist | -20% move speed, -15% fire rate |
| **Simon** | Fast glass cannon | **Quick Dash** — fast short-dash with invulnerability (2s CD) | +25% speed, +15% fire rate | -30% HP |


### ❤️ Progression & Systems
- **XP & Leveling:** Kill enemies to earn XP. Each level-up lets you choose from randomized perks.
- **6 Perks:** Move Speed +10%, +1 Max HP, Bullet Pierce +1, Fire Rate +20%, Damage +1, Crit Chance +5%.
- **Combo System:** Chain kills within 2 seconds to build a kill streak. Higher combos = massive score bonuses.
- **Difficulty Selection:** Choose Easy (0.5x enemies), Normal (1x), or Hard (1.5x) before starting.
- **Persistent Progression:** Highscores, total kills, max wave, max streak, max level, and coins collected are saved between sessions.


## 🎮 Controls

| Action | Keybinding / Input |
|---|---|
| **Move** | `W`, `A`, `S`, `D` / Arrow Keys |
| **Aim** | Mouse |
| **Shoot** | `Left Mouse Button` / `Z` |
| **Dash** | `Space` / `Shift` |
| **Ability** | `F` / `X` |
| **Reload** | `R` |
| **Pause** | `Esc` / `P` |

---

## 🎲 Game Flow

```
Main Menu
  ├── Settings (Audio, Fullscreen)
  ├── Achievements (Persistent tracker)
  └── Start → Character Select (Shooter / Rocky / Simon)
                └── Difficulty (Easy / Normal / Hard)
                      └── Game Scene
                            ├── Wave 1: Shop opens (30s timer)
                            │     └── Buy weapon or auto-equip cheapest
                            ├── Waves 1-3: Shop after each wave
                            ├── Wave 4: Scene weapon drops
                            ├── Wave 5: ⚠ BOSS WAVE ⚠
                            ├── Waves 6-8: Shop after each wave
                            ├── Wave 8: Scene weapon drops again
                            └── Repeat cycle...
```

## 🏗️ Project Architecture

### AutoLoads (Singletons)

| Script | Purpose |
|---|---|
| `GameConfig.gd` | Central configuration hub — 100+ exported parameters for every tunable value in the game |
| `GameManager.gd` | Global game state — score, XP, coins, achievements, signals, save/load |
| `SoundManager.gd` | Audio playback — SFX for clicks, level-ups, achievements |

### Directory Structure

```
Onslaught/
├── Assets/                    # Sprites, fonts, audio, shaders
│   ├── Fonts/                 # kenpixel_mini_square.ttf
│   ├── Sprites/               # Player, Enemy, UI, Achievement icons
│   └── Sounds/                # SFX files
├── AutoLoad/                  # Global singletons
│   ├── GameConfig.gd          # All tunable game parameters
│   ├── GameManager.gd         # State, signals, save system
│   └── SoundManager.gd        # Audio management
├── Data/                      # Weapon resource files (.tres)
│   ├── W_AKM.tres
│   ├── W_AR.tres
│   ├── W_Auto_Pistol.tres
│   ├── W_DoubleShotGun.tres
│   ├── W_HandGun.tres
│   ├── W_M24.tres
│   ├── W_M4.tres
│   ├── W_M416.tres
│   ├── W_Pistol.tres
│   ├── W_ShotGun.tres
│   └── W_UZI.tres
├── Material/                  # Shader materials (hit flash, heal)
├── Scenes/                    # Categorized .tscn scene files
│   ├── Core/                  # Game, Minimap, Overlays
│   ├── UI/                    # Menus, HUD, Settings, Achievements
│   ├── Player/                # Playable character scenes
│   ├── Enemy/                 # Mobs, Bosses, Spawners
│   ├── Weapon/                # Guns, Bullets, Shop
│   ├── Effect/                # VFX, Damage Text, Particles
│   └── Pickup/                # Coins, Health, Powerups
├── Scripts/                   # Categorized GDScript files
│   ├── Core/                  # Main loop, Camera, etc.
│   ├── UI/                    # UI logic, Menu handling
│   ├── Player/                # Movement, Health, Abilities
│   ├── Enemy/                 # AI, Spawning logic
│   ├── Weapon/                # Firing logic, Data resources
│   ├── Effect/                # Animation handling
│   └── Pickup/                # Collectible logic
└── project.godot              # Godot project configuration
```

### Key Design Patterns

- **Data-Driven Weapons:** All weapon stats live in `.tres` resource files using the `WeaponData` class. Adding a new weapon is as simple as creating a new `.tres` file.
- **Signal-Based Communication:** `GameManager` exposes signals (`on_enemy_died`, `on_level_up`, `on_combo_broken`, etc.) that decouple systems cleanly.
- **Scene-Based UI:** Achievement toasts, shop cards, and perk cards are built as reusable `.tscn` scenes — no hardcoded UI instantiation.
- **Config-Driven Tuning:** `GameConfig.gd` exports 100+ parameters, making the game fully tunable from the inspector without touching code.

---

## 🌐 Web Export (itch.io)

This project is fully compatible with Godot 4 HTML5 web exports. The following web-specific adaptations are built in:

- **Threaded Loading Fallback:** `CharacterSelect.gd` detects web platform via `OS.has_feature("web")` and falls back to synchronous scene loading (threaded loading is unstable on web).
- **AudioStreamGenerator Bypass:** Procedural footstep audio is disabled on web (`OS.get_name() == "Web"`) to avoid `AudioStreamGenerator` buffer push failures.
- **Windowed Mode Default:** `project.godot` uses `window/size/mode=0` (windowed) instead of fullscreen to avoid browser autoplay restrictions. A Fullscreen button is available on the Main Menu.
- **Quit Button Hidden:** The "QUIT" button is automatically hidden on web builds since `get_tree().quit()` has no meaning in a browser.
- **Preloaded Weapons:** `WeaponShop.gd` uses `preload()` instead of `DirAccess` directory scanning, which doesn't work on web exports.
- **Save Data:** Highscores are saved to `user://` which maps to IndexedDB on web — persistent but clearable by the user.

---

## 🛠️ Installation & Setup

### From Source (Editor)

1. **Download Godot:** Ensure you have [Godot Engine 4.6+](https://godotengine.org/download/) installed.
2. **Clone the Repository:**
   ```bash
    git clone https://github.com/YumiNoona/Onslaught.git
   ```
3. **Import Project:** Open Godot → **Import** → select the `project.godot` file.
4. **Play:** Press `F5` to run the game!

### Web Build (itch.io)

1. In Godot, go to **Project → Export → Add → Web**
2. Export the project as HTML5
3. Upload the exported files to [itch.io](https://itch.io/) as an HTML game
4. Set the viewport size to **1920×1080** in itch.io's embed settings

---

## ⚙️ Configuration

All game parameters are centralized in `AutoLoad/GameConfig.gd` and can be tweaked from the Godot inspector without modifying code. Categories include:

| Category | Examples |
|---|---|
| **Slow Motion** | Death time scale, duration |
| **Camera Shake** | Per-event shake intensities |
| **Player Stats** | Move speed, max health, health on level-up |
| **Player Dash** | Speed, duration, cooldown, trail settings |
| **Character Abilities** | Cooldowns, durations, multipliers per character |
| **Enemy Stats** | Move speed, contact damage, stop distance |
| **Enemy Spawner** | Base enemies per wave, HP scaling, spawn timers |
| **Boss** | Attack cooldowns, enrage threshold, coin drops |
| **Death Particles** | Particle count, lifetime, velocity, scale |
| **Bullet** | Speed, trail length, hit spark effects |
| **Power-Ups** | Duration, speed multiplier, damage bonus |
| **Economy** | Starting coins, magnet radius, coin physics |
| **XP & Leveling** | Base XP, curve multiplier, perk choice count |
| **Difficulty** | Easy/Normal/Hard multipliers |
| **Wave Intermission** | Timer between waves, first wave timer, boss interval, shop cycle |

---

## 📜 License

This project is open-source and distributed under the **MIT License**. You are free to use, modify, and distribute the code as you see fit. See the [LICENSE](LICENSE) file for more details.

<p align="center"><b>Made with 💙 By Veil</b></p>
