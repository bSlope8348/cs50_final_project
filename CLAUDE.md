# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

JumpSim is a 2D platformer game built with Lua and the LÖVE2d framework (version 11.4) that records player scores in a local SQLite3 database. This was created as a CS50 final project to learn Lua, game development, and SQL integration.

## Development Commands

### Running the Game
From the `game/` directory:
```bash
lovec .
```

Or from the `tools/` directory using npm scripts:
```bash
npm run Run
```

### Building the Game
Build executables for multiple platforms using makelove from the `tools/` directory:
```bash
npm run Build
```

This creates builds in `../builds/` for: win32, win64, lovejs (web), and macos. For Linux builds (appimage), makelove must be run from WSL2.

The build configuration is in `tools/build/makelove.toml`.

## Code Architecture

### Core Game Loop (game/main.lua)
The main file orchestrates the entire game using LÖVE's lifecycle:
- `love.load()`: Initializes game state, opens/creates SQLite database, loads all entities from the map array
- `love.update(dt)`: Updates all entities, resolves collisions in a loop (max 1000 iterations), manages timer, handles pause/name input states
- `love.draw()`: Renders entities, UI elements, and victory/pause overlays
- `love.keypressed()`: Handles player input and triggers the timer on first key press

### Entity System (game/src/entity.lua)
The base Entity class (using classic.lua OOP library) provides:
- Collision detection via AABB (axis-aligned bounding box) checking
- Collision resolution using a strength-based system (higher strength entities push lower strength ones)
- Gravity and physics for all entities
- Historical position tracking (`last.x`, `last.y`) to determine collision direction

All game objects extend Entity: Player, Box, Coin, Exit, Wall, Floor, ThruFloor.

### Object Hierarchy
- **Player** (strength: 10): Two playable characters, controlled with WASD/arrows/space. Changes sprite when collecting coin.
- **Box** (strength: 5): Pushable object, weaker than players but stronger than static objects.
- **Coin**: Collectible that makes the exit accessible when picked up by a player.
- **Exit**: Becomes visible (transparency: 1) when coin is collected. Triggers victory when player with coin enters.
- **Wall/Floor**: Static collision boundaries (strength: 0).
- **ThruFloor**: Platform that can only be collided with from above.

### Collision Resolution
The collision system in main.lua uses a `while loop` that iterates until no collisions occur (with a 1000-iteration safety limit). This resolves chains of collisions like player pushing box into wall. Known bug: multiple players pushing a box can occasionally cause one player to "pop" through the box.

### SQLite Database Integration (game/lib/sqlite3.lua)
- Database stored in LÖVE's save directory: `AppData/Roaming/LOVE/JumpSim/gameDB.db` (Windows)
- Creates `log` table with: id, name, time_completed, first_key_used, date_logged
- SQL injection prevention via `escapeSQLString()` function (doubles single quotes)
- Inserts completion record on victory
- Queries for top 10 scores and player rank

### UI Components (game/src/ui/)
- **name.lua**: Uses InputField.lua library for text input at game start
- **pause.lua**: Menu with resume, save, load, top scores, restart, exit. Connects to main.lua's save/load functions via callbacks.
- **scoreBox.lua**: Displays the running timer

### Save System
Uses lume.serialize() to save/load game state to `quicksave.txt`:
- Timer state and value
- All entity positions and properties
- Player states (hasCoin, canJump, image_path)
- Exit transparency and victory state

### Map System
The level is defined as a 2D array (16x12) in main.lua where:
- 1 = Wall
- 2 = Player spawn
- 3 = Exit
- 4 = Box
- 5 = Floor
- 6 = ThruFloor
- 7 = Coin

Each tile is 80x80 pixels, creating a 1280x960 game window.

## Key Libraries
- **classic.lua**: Lightweight OOP library for class inheritance
- **sqlite3.lua**: Full SQLite3 integration for Lua
- **InputField.lua**: Text input field widget
- **lume.lua**: Utility library used for serialization

## Project Structure
```
game/
├── conf.lua          # LÖVE configuration (window size, title, modules)
├── main.lua          # Main game logic and entry point
├── assets/           # PNG sprites (from kenney.nl)
├── lib/              # External Lua libraries
└── src/
    ├── entity.lua       # Base entity class with collision system
    ├── player.lua       # Player entity (extends Entity)
    ├── box.lua          # Box entity
    ├── coin.lua         # Coin entity
    ├── exit.lua         # Exit entity
    ├── wall.lua         # Wall entity
    ├── floor.lua        # Floor entity
    ├── thruFloor.lua    # Pass-through floor entity
    └── ui/
        ├── name.lua      # Name input screen
        ├── pause.lua     # Pause menu
        └── scoreBox.lua  # Timer display

builds/          # Output directory for compiled executables
tools/           # Build configuration and npm scripts
resources/       # Development resources (not shipped)
```

## Important Patterns

### Entity Collision Flow
1. Entity moves in `update(dt)`
2. Main loop checks `checkCollision()` between all entities
3. If collision detected, `resolveCollision()` determines direction based on `last.x/y`
4. Entity with lower `tempStrength` calls `checkResolve()` on both parties (can veto collision)
5. If both agree, `collide()` pushes entity back and resets gravity if needed
6. Loop continues until no collisions remain

### State Management
The game has three states managed in `love.update()`:
1. **Startup** (`not startUp`): Shows name input screen
2. **Playing** (`startUp and not isPaused`): Normal gameplay with timer running
3. **Paused** (`isPaused`): Shows pause menu, timer stops

### Timer System
- Timer starts on first key press (`noKeyPressedYet` flag)
- Tracks `firstKey` pressed for database logging
- Pauses when game loses focus (`love.focus()`)
- Freezes on victory or pause

## Database Queries
See README.md lines 59-90 for the SQL schema and query examples used for CREATE, INSERT, and SELECT operations.
