# Asteroid Blaster

Asteroid Blaster is a fast-paced arcade space shooter built in **Lua** with **PICO-8**.

The player controls a spaceship, fires rainbow projectiles, and destroys randomly generated asteroids while trying to survive as long as possible and beat their high score.

## Demo

Add a screenshot, GIF, or gameplay clip here if you want visitors to see the game immediately.

## Features

- Responsive four-direction player movement
- Rapid-fire rainbow projectiles
- Randomized asteroid spawning
- Three asteroid sizes with different health values
- Multi-hit asteroid damage system
- Visual asteroid damage cracks
- Projectile-to-asteroid collision detection
- Player-to-asteroid collision detection
- Three-hit player health system
- Score system based on asteroid difficulty
- Persistent high-score storage
- Scrolling star-field background
- Game-over and restart system

## Controls

| Control | Action |
| --- | --- |
| Arrow Keys | Move |
| V / PICO-8 Button 5 | Shoot |
| V after Game Over | Restart |

## Scoring

- Small asteroid: **10 points**
- Medium asteroid: **20 points**
- Large asteroid: **30 points**

Larger asteroids require more hits to destroy.

## Built With

- Lua
- PICO-8
- Procedural drawing with PICO-8 graphics functions
- PICO-8 persistent cartridge data

## Running the Game

Open the `.p8` cartridge in PICO-8 and run:

```text
run
```

The game can also be opened in the PICO-8 Education Edition if the cartridge is imported there.

## Project Structure

```text
asteroid-blaster-kishore-jason.p8
README.md
```

The game uses procedural graphics, so no external sprite assets are required.

## Implementation

Game state is stored in Lua tables for the player, bullets, asteroids, and background stars.

PICO-8's main game loop is split across:

- `_init()` for initialization and saved high-score loading
- `_update()` for movement, spawning, shooting, collisions, scoring, and health
- `_draw()` for rendering the game world and UI

Asteroids are generated with randomized sizes, speeds, and visual crater patterns. Larger asteroids have more health and award more points when destroyed.

## Author

Jason Kishore
