# Web release (arcade.azhang.me/pokesurvivor/)

- `web/build.sh` exports the "Web" preset (single-threaded, Compatibility renderer)
  to `build/web/` and packages it into `web/dist/`.
- `web/build.sh deploy` also deploys `web/dist/` to the `fin-fur-pokesurvivor`
  Worker, using the Arcade checkout's Wrangler login
  (`/run/media/adam-zhang/SERVE/Projects/ChatGPT/Arcade/.local-config`).
- `package.mjs` splits files over Cloudflare's 25 MiB asset limit into hashed
  chunks. `chunk-loader.js` streams them back together in the browser.

Web-specific game changes: `scripts/display.gd` (a desktop browser counts as PC,
fullscreen only from the settings toggle), `scripts/menu.gd` (no APK update
check, no quit, "· Web" version label, no window-resolution row) and
`scripts/arena.gd` (the arena bake runs in frame slices instead of on a Thread).
