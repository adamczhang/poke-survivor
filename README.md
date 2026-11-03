# Pokémon Survivors — Android port

> **This fork (adamczhang/poke-survivor)** is a kid-friendly version of the game, played in the
> browser at **https://arcade.azhang.me/pokesurvivor/**. Its changes sit behind **Simple Mode**, which is
> on by default and can be switched off in Settings to get the original game back:
> every Pokémon unlocked (no starter quiz), every move auto-fires, Play starts a Normal run (the gear
> next to it picks another mode), and the menu has no gacha, TM gachapon or missions.
> Web build and deploy: see [`web/README.md`](web/README.md). Upstream port:
> [JayElDragon/poke-survivor](https://github.com/JayElDragon/poke-survivor); original game:
> [JPTER78/pokesurvivor](https://github.com/JPTER78/pokesurvivor). Credits and licenses below still apply.

A free, fan-made Android port of **[PokéSurvivor](https://github.com/JPTER78/pokesurvivor) by JPTER78**, built with Godot. Survive endless waves of Pokémon, level up, evolve your moves, enter rifts to fight legendaries and face the Judgment of Arceus.

**Port by [JayElDragon](https://github.com/JayElDragon).** All game design, systems and content come from the original game.

## Features
- Touch controls (floating or fixed joystick) and gamepad support with **Xbox, PlayStation and Nintendo** layouts, fully remappable
- 11 languages: English, Español (España / Latinoamérica), Français, Italiano, Português (Brasil / Portugal), Русский, 日本語, 中文（普通话）, 廣東話
- Notch-safe UI, minimap, field-of-view slider, quality and accessibility options
- 960+ Pokémon, gacha, permanent upgrades, missions, 130 achievements, trainer profile
- Offline only: no ads, no purchases, no online features

## Download
Get the APK from the [Releases](../../releases) page.

## Build
1. Install [Godot 4](https://godotengine.org/) with the Android export templates.
2. Open `project.godot`, let it import, then export with the included Android preset.

## Credits and licenses
- Code: MIT (see [`LICENSE`](LICENSE)). Sprites: CC BY-NC 4.0, non-commercial use only. Full artist list in [`CREDITS.md`](CREDITS.md).
- Pokémon and its characters are trademarks of Nintendo, Creatures Inc. and GAME FREAK inc. This is a non-profit fan project with no affiliation to them.
