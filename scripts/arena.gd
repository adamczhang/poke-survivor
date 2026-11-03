extends Node2D
# Arena de la grieta (rift.js + world.js + tiles.js del juego original): un circulo cerrado
# de 11 tiles con suelo, paredes, columnas 2x2, charcos y decoracion segun el tipo.
# Este nodo se coloca en el centro de la arena (coordenadas de mundo lejanas).

const TS := 48.0
const OUTER := 7
const FLOOR := 0
const WALL := 1
const LIQUID := 2
const VOID := 3

const THEMES := {
	"normal": {"name": "Pradera Eterna", "floor": "#6f8a4f", "wall": "#8a7f6a", "liquid": "water", "liq": "#4f8fd0", "prop": "tree", "leaf": "#5aa04a", "trunk": "#6b4a2a", "grass": "#5a9a40", "rock": "#8a8a8a", "pools": 0, "pillars": 0.035, "weather": "", "props": {"tree": 0.025, "grass": 0.05}, "flowers": ["#f4d65c", "#ffffff", "#f39ac0"]},
	"fire": {"name": "Volcán Ígneo", "floor": "#5b3a2e", "wall": "#3a2826", "liquid": "lava", "liq": "#e45a1f", "foam": "#ffd46a", "prop": "dead", "leaf": "#5e4a3c", "trunk": "#3a2e27", "grass": "#94693a", "rock": "#6a605b", "pools": 0.31, "pillars": 0.03, "weather": "sun", "props": {"tree": 0.01}, "flowers": ["#ff8d3d", "#ffc45e", "#e06a4a"]},
	"water": {"name": "Gruta Marina", "floor": "#3c6a80", "wall": "#2a4660", "liquid": "water", "liq": "#2f86d6", "foam": "#bfeaff", "prop": "crystal", "leaf": "#5fd0e8", "trunk": "#2a4a78", "grass": "#3f8a9a", "rock": "#5d7a90", "pools": 0.33, "pillars": 0.02, "weather": "rain", "props": {"tree": 0.015}, "flowers": ["#ff9ec4", "#7ef0d0", "#ffffff"]},
	"grass": {"name": "Selva Esmeralda", "floor": "#3a7a32", "wall": "#4a6a36", "liquid": "swamp", "liq": "#4f6b2a", "foam": "#9ac25a", "prop": "tree", "leaf": "#3f9a3a", "trunk": "#5b3b22", "grass": "#4caa3f", "rock": "#6a7a5a", "pools": 0.22, "pillars": 0, "weather": "", "props": {"tree": 0.05, "grass": 0.12}, "flowers": ["#f4d65c", "#ff8ad8", "#ffffff"]},
	"electric": {"name": "Central Voltio", "floor": "#4a4840", "wall": "#3a3a48", "liquid": "spark", "liq": "#e8c020", "foam": "#fff6c0", "prop": "crystal", "leaf": "#ffd23f", "trunk": "#5a5030", "grass": "#8a8a40", "rock": "#70707a", "pools": 0.28, "pillars": 0.04, "weather": "rain", "props": {"tree": 0.01}, "flowers": ["#ffe14d", "#ffffff", "#7fd0ff"]},
	"ice": {"name": "Glaciar Eterno", "floor": "#b8cfe0", "wall": "#7f9fc0", "liquid": "ice", "liq": "#9fd8f0", "foam": "#ffffff", "prop": "crystal", "leaf": "#bfe8ff", "trunk": "#6f8fb0", "grass": "#9fc0d8", "rock": "#8fa8c0", "pools": 0.36, "pillars": 0.02, "weather": "snow", "props": {"tree": 0.02}, "flowers": ["#ffffff", "#9fe0ff", "#d8f1ff"]},
	"fighting": {"name": "Dojo Ancestral", "floor": "#8a6a46", "wall": "#5e4232", "liquid": "water", "liq": "#4f8fd0", "prop": "tree", "leaf": "#4f8a3a", "trunk": "#5b3b22", "grass": "#6a8a40", "rock": "#8a7a6a", "pools": 0, "pillars": 0.075, "weather": "", "props": {"tree": 0.008}, "flowers": ["#ff5f6d", "#f4d65c", "#ffffff"]},
	"poison": {"name": "Ciénaga Tóxica", "floor": "#46384f", "wall": "#33263f", "liquid": "poison", "liq": "#9a4fc0", "foam": "#e0a6ff", "prop": "dead", "leaf": "#5a4a6a", "trunk": "#3a2f45", "grass": "#6a5a8a", "rock": "#5a4f6a", "pools": 0.31, "pillars": 0.015, "weather": "", "props": {"tree": 0.02}, "flowers": ["#c86bdc", "#8bd94a", "#e0a6ff"]},
	"ground": {"name": "Desierto Rojo", "floor": "#b08a52", "wall": "#8a5e34", "liquid": "swamp", "liq": "#9a7a48", "foam": "#d6b98a", "prop": "dead", "leaf": "#8a6a40", "trunk": "#6a4a2a", "grass": "#b0904a", "rock": "#9a7a5a", "pools": 0.25, "pillars": 0.04, "weather": "sand", "props": {"tree": 0.01, "rock": 0.015}, "flowers": ["#e06a4a", "#f4d65c", "#ffffff"]},
	"flying": {"name": "Pico Celeste", "floor": "#9fb8d8", "wall": "#dfe8f4", "liquid": "water", "liq": "#7fb8ff", "prop": "tree", "leaf": "#e8f2ff", "trunk": "#9aa8c0", "grass": "#b8d0e8", "rock": "#c0ccdc", "pools": 0, "pillars": 0.02, "weather": "", "props": {"tree": 0.025}, "flowers": ["#ffffff", "#ffe14d", "#bfe0ff"]},
	"psychic": {"name": "Templo Mental", "floor": "#5e4470", "wall": "#3e2a55", "liquid": "water", "liq": "#8a5ad0", "prop": "crystal", "leaf": "#ff8ad8", "trunk": "#5a3a7a", "grass": "#8a5a9a", "rock": "#7a6a8a", "pools": 0, "pillars": 0.045, "weather": "", "props": {"tree": 0.02}, "flowers": ["#ff8ad8", "#c9a6ff", "#ffffff"]},
	"bug": {"name": "Bosque Colmena", "floor": "#5a6a2a", "wall": "#5e4a26", "liquid": "swamp", "liq": "#6a7a2a", "foam": "#c4d65a", "prop": "tree", "leaf": "#8aaa30", "trunk": "#5b3b22", "grass": "#8aaa30", "rock": "#7a7a5a", "pools": 0.2, "pillars": 0, "weather": "", "props": {"tree": 0.04, "grass": 0.12}, "flowers": ["#f4d65c", "#ffffff", "#c4d65a"]},
	"rock": {"name": "Cantera Antigua", "floor": "#7a6a58", "wall": "#55473a", "liquid": "water", "liq": "#4f8fd0", "prop": "dead", "leaf": "#6a5a4a", "trunk": "#4a3e32", "grass": "#8a7a5a", "rock": "#8a7a6a", "pools": 0, "pillars": 0.08, "weather": "sand", "props": {"rock": 0.03}, "flowers": ["#c9b28a", "#ffffff", "#a89070"]},
	"ghost": {"name": "Cementerio Sombrío", "floor": "#383447", "wall": "#24202e", "liquid": "water", "liq": "#3a3a6a", "prop": "dead", "leaf": "#4a4060", "trunk": "#2e2838", "grass": "#4a4a60", "rock": "#5a5670", "pools": 0, "pillars": 0.03, "weather": "fog", "props": {"tree": 0.03}, "flowers": ["#9a8ad0", "#5fe0c0", "#c9cfdc"]},
	"dragon": {"name": "Santuario Dragón", "floor": "#363a5e", "wall": "#24264a", "liquid": "lava", "liq": "#7b5cff", "foam": "#c9a6ff", "prop": "crystal", "leaf": "#7b5cff", "trunk": "#2a2a5a", "grass": "#4a4a8a", "rock": "#5a5a8a", "pools": 0.22, "pillars": 0.04, "weather": "", "props": {"tree": 0.015}, "flowers": ["#7b5cff", "#ffd23f", "#ffffff"]},
	"dark": {"name": "Callejón Oscuro", "floor": "#2c282e", "wall": "#1c181f", "liquid": "water", "liq": "#2a2a3a", "prop": "dead", "leaf": "#3a3040", "trunk": "#241e28", "grass": "#3a343a", "rock": "#4a444a", "pools": 0, "pillars": 0.05, "weather": "", "props": {"tree": 0.02}, "flowers": ["#ff5f6d", "#6b5c52", "#9a8a9a"]},
	"steel": {"name": "Fortaleza de Acero", "floor": "#6d7888", "wall": "#465060", "liquid": "water", "liq": "#4f8fd0", "prop": "crystal", "leaf": "#c9d2de", "trunk": "#5d6773", "grass": "#8a96a6", "rock": "#9aa6b5", "pools": 0, "pillars": 0.08, "weather": "", "props": {"tree": 0.01}, "flowers": ["#c9d2de", "#ffd23f", "#ffffff"]},
	"fairy": {"name": "Bosque Encantado", "floor": "#4f7f5a", "wall": "#7a5a8a", "liquid": "water", "liq": "#8fd8ff", "foam": "#ffe0f4", "prop": "tree", "leaf": "#e08ad0", "trunk": "#6b4a5a", "grass": "#c48ad8", "rock": "#9a8aa8", "pools": 0.16, "pillars": 0, "weather": "", "props": {"tree": 0.05, "grass": 0.1}, "flowers": ["#ff8ad8", "#ffffff", "#c9a6ff"]},
	"judgment": {"name": "Ruinas del Juicio", "floor": "#4a4240", "wall": "#2e2829", "liquid": "lava", "liq": "#e8a82a", "foam": "#fff1b8", "prop": "dead", "leaf": "#3e3633", "trunk": "#2a2321", "grass": "#5e544c", "rock": "#6a625c", "pools": 0, "pillars": 0.03, "weather": "", "clear": 4.5, "props": {"tree": 0.012, "rock": 0.02}, "flowers": ["#8a7f76", "#e8a82a", "#5a514c"]},
}


var type := "normal"
var th: Dictionary = {}
var seed_v := 0
var r := 11.0
var cache := {}
var palette := {}
var solids: Array = []      # [pos, radio] de arboles y rocas
var prop_nodes: Array = []
var _built := false


static func hsh(x: int, y: int, s: int) -> float:
	# Mismo hash de 32 bits que util.js del original (Math.imul).
	var h: int = ((x * 374761393) & 0xFFFFFFFF) ^ ((y * 668265263) & 0xFFFFFFFF) ^ ((s * 2246822519) & 0xFFFFFFFF)
	h = (((h ^ (h >> 13)) & 0xFFFFFFFF) * 1274126177) & 0xFFFFFFFF
	h = h ^ (h >> 16)
	return float(h) / 4294967296.0


static func vnoise(x: float, y: float, s: int) -> float:
	var xi: int = int(floorf(x))
	var yi: int = int(floorf(y))
	var xf: float = x - float(xi)
	var yf: float = y - float(yi)
	var u: float = xf * xf * (3.0 - 2.0 * xf)
	var v: float = yf * yf * (3.0 - 2.0 * yf)
	var a: float = hsh(xi, yi, s)
	var b: float = hsh(xi + 1, yi, s)
	var c: float = hsh(xi, yi + 1, s)
	var d: float = hsh(xi + 1, yi + 1, s)
	return (a + (b - a) * u) * (1.0 - v) + (c + (d - c) * u) * v


static func fbm(x: float, y: float, s: int) -> float:
	return vnoise(x, y, s) * 0.65 + vnoise(x * 2.13 + 17.0, y * 2.13 - 9.0, s + 1) * 0.35


static func shade(c: Color, k: float) -> Color:
	if k >= 0.0:
		return Color(c.r + (1.0 - c.r) * k, c.g + (1.0 - c.g) * k, c.b + (1.0 - c.b) * k, 1.0)
	return Color(c.r * (1.0 + k), c.g * (1.0 + k), c.b * (1.0 + k), 1.0)


static func make_palette(th: Dictionary) -> Dictionary:
	var f := Color(String(th["floor"]))
	var w := Color(String(th["wall"]))
	var lq := Color(String(th["liq"]))
	var lf := Color(String(th["leaf"]))
	var tk := Color(String(th["trunk"]))
	var rk := Color(String(th["rock"]))
	var gr := Color(String(th["grass"]))
	var fls: Array = []
	for h in th["flowers"]:
		fls.append(Color(String(h)))
	return {
		"floor": [f, shade(f, 0.05), shade(f, -0.06)], "dirt": [shade(f, -0.16), shade(f, -0.12), shade(f, -0.2)],
		"speck": shade(f, -0.25), "light": shade(f, 0.22), "flowers": fls,
		"wallTop": [w, shade(w, 0.07), shade(w, -0.07)], "wallLight": shade(w, 0.32), "wallEdge": shade(w, -0.7),
		"wallFace": [shade(w, -0.3), shade(w, -0.38)], "wallFaceDark": shade(w, -0.55), "bg": shade(w, -0.8),
		"liq": lq, "liqDeep": shade(lq, -0.22),
		"foam": Color(String(th["foam"])) if th.has("foam") else shade(lq, 0.55),
		"shore": shade(f, -0.32), "liquid": String(th.get("liquid", "water")), "prop": String(th.get("prop", "tree")),
		"leaf": [shade(lf, -0.35), shade(lf, -0.15), lf, shade(lf, 0.3)],
		"trunk": [shade(tk, -0.2), tk],
		"rock": [shade(rk, -0.2), rk, shade(rk, 0.22)],
		"grass": [shade(gr, -0.28), gr, shade(gr, 0.28)],
	}


func setup(t: String, sd: int) -> void:
	type = t if THEMES.has(t) else "normal"
	th = THEMES[type]
	seed_v = sd
	palette = make_palette(th)
	cache.clear()


func liquid_kind() -> String:
	return String(th.get("liquid", "water"))


func _safe(lx: int, ly: int) -> bool:
	if absi(lx) <= 2 and ly >= -6 and ly <= 5:
		return true
	if Vector2(lx, ly).length() < 2.5:
		return true
	var clr: float = float(th.get("clear", 0.0))
	return clr > 0.0 and Vector2(lx, ly + 5).length() < clr


func terrain(lx: int, ly: int) -> int:
	var key := Vector2i(lx, ly)
	if cache.has(key):
		return cache[key]
	var res := FLOOR
	var ad: float = Vector2(lx, ly).length()
	if ad >= r:
		res = WALL if ad < r + float(OUTER) else VOID
	elif _safe(lx, ly):
		res = FLOOR
	else:
		var pil: float = float(th.get("pillars", 0.0))
		var pools: float = float(th.get("pools", 0.0))
		if pil > 0.0 and ad < r - 2.0 and hsh(lx >> 1, ly >> 1, seed_v + 31) < pil:
			res = WALL
		elif pools > 0.0 and ad < r - 1.5 and fbm(float(lx) / 3.2, float(ly) / 3.2, seed_v + 37) < pools:
			res = LIQUID
	cache[key] = res
	return res


func tile_of(pos: Vector2) -> Vector2i:
	var l: Vector2 = pos - global_position
	return Vector2i(int(roundf(l.x / TS)), int(roundf(l.y / TS)))


func liquid_at(pos: Vector2) -> String:
	var t: Vector2i = tile_of(pos)
	if terrain(t.x, t.y) == LIQUID:
		return liquid_kind()
	return ""


static func push_rect(pos: Vector2, rad: float, g: Rect2) -> Vector2:
	var q := Vector2(clampf(pos.x, g.position.x, g.end.x), clampf(pos.y, g.position.y, g.end.y))
	var d: Vector2 = pos - q
	var dd: float = d.length_squared()
	if q == pos:
		var dl: float = pos.x - g.position.x
		var dr: float = g.end.x - pos.x
		var dt: float = pos.y - g.position.y
		var db: float = g.end.y - pos.y
		var m: float = minf(minf(dl, dr), minf(dt, db))
		if m == dl:
			pos.x = g.position.x - rad
		elif m == dr:
			pos.x = g.end.x + rad
		elif m == dt:
			pos.y = g.position.y - rad
		else:
			pos.y = g.end.y + rad
	elif dd < rad * rad:
		pos = q + d.normalized() * rad
	return pos


func collide(pos: Vector2, rad: float) -> Vector2:
	var t: Vector2i = tile_of(pos)
	var org: Vector2 = global_position
	for dy in range(-2, 3):
		for dx in range(-2, 3):
			var tt: int = terrain(t.x + dx, t.y + dy)
			if tt == WALL or tt == VOID:
				var rc := Rect2(org + Vector2((float(t.x + dx) - 0.5) * TS, (float(t.y + dy) - 0.5) * TS), Vector2(TS, TS))
				pos = push_rect(pos, rad, rc)
	for s in solids:
		var d: Vector2 = pos - (s[0] as Vector2)
		var md: float = float(s[1]) + rad
		var dd: float = d.length_squared()
		if dd < md * md:
			if dd < 0.0001:
				d = Vector2(1, 0)
			pos = (s[0] as Vector2) + d.normalized() * md
	return pos


# ---------------------------------------------------------------
# Dibujo (estatico: se dibuja una vez)
# ---------------------------------------------------------------
# Pixel art como el original (tiles.js): 16 px de arte por tile, escalado x3
# ---------------------------------------------------------------
const T := 16
const PX := 3.0

var baked_img: Image = null
var tex: ImageTexture = null
var prop_imgs := {}
var prop_texs := {}
var liquid_tiles: Array = []
var _thread: Thread = null
# Web port: the single-threaded web build cannot bake on a Thread, so it bakes in slices across frames.
var _baking := false
var _bake_abort := false
const SLICE_USEC := 6000


static func pk(c: Color) -> int:
	return c.to_abgr32()


class Pix extends RefCounted:
	var w := 0
	var h := 0
	var buf := PackedByteArray()

	func _init(ww: int, hh: int) -> void:
		w = ww
		h = hh
		buf.resize(ww * hh * 4)

	func set_px(x: int, y: int, col: int) -> void:
		if x >= 0 and y >= 0 and x < w and y < h:
			buf.encode_u32((y * w + x) * 4, col)

	func alpha(x: int, y: int) -> int:
		return buf[(y * w + x) * 4 + 3]

	func img() -> Image:
		return Image.create_from_data(w, h, false, Image.FORMAT_RGBA8, buf)

	func dup() -> Pix:
		var p := Pix.new(w, h)
		p.buf = buf.duplicate()
		return p

	func outline(col: int) -> void:
		var marks: Array = []
		for y in range(h):
			for x in range(w):
				if alpha(x, y) > 0:
					continue
				for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
					var xx: int = x + d.x
					var yy: int = y + d.y
					if xx >= 0 and yy >= 0 and xx < w and yy < h and alpha(xx, yy) > 0:
						marks.append(Vector2i(x, y))
						break
		for m in marks:
			set_px(m.x, m.y, col)


func start_bake() -> void:
	if OS.has_feature("web"):
		_bake_sliced()
		return
	_thread = Thread.new()
	_thread.start(bake)


func _bake_sliced() -> void:
	_baking = true
	_bake_abort = false
	await bake(true)
	_baking = false


func finish_bake() -> void:
	# Web: if the sliced bake has not finished yet, stop it and finish synchronously.
	if _baking:
		_bake_abort = true
		_baking = false
		baked_img = null
	if _thread != null:
		if _thread.is_started():
			_thread.wait_to_finish()
		_thread = null
	if baked_img == null:
		bake()
	if tex == null:
		tex = ImageTexture.create_from_image(baked_img)
		for k in prop_imgs:
			prop_texs[k] = ImageTexture.create_from_image(prop_imgs[k])


func dispose() -> void:
	_bake_abort = true
	if _thread != null and _thread.is_started():
		_thread.wait_to_finish()
	_thread = null
	if is_inside_tree():
		queue_free()
	else:
		call_deferred("free")


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE and _thread != null and _thread.is_started():
		_thread.wait_to_finish()


func _at(tx: int, ty: int) -> int:
	var t: int = terrain(tx, ty)
	return WALL if t == VOID else t


# step=true (web only) yields to the next frame every SLICE_USEC so the game keeps running.
# With step=false it never awaits, so it still runs synchronously (and on a Thread) as before.
func bake(step: bool = false) -> void:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	var t0: int = Time.get_ticks_usec()
	var span: int = int(r) + OUTER
	var n: int = span * 2 + 1
	var W: int = n * T
	var P := Pix.new(W, W)
	var C := {}
	for k in ["floor", "dirt", "wallTop", "wallFace"]:
		var a: Array = []
		for c in palette[k]:
			a.append(pk(c))
		C[k] = a
	var fl: Array = []
	for h in th["flowers"]:
		fl.append(pk(Color(String(h))))
	C["flowers"] = fl
	for k in ["speck", "light", "wallLight", "wallEdge", "liq", "liqDeep", "foam", "shore"]:
		C[k] = pk(palette[k])
	C["wallFaceDark"] = pk(palette["wallFaceDark"])
	C["liqLight"] = pk(palette["liq"].lerp(palette["foam"], 0.28))
	# mascara de tierra a resolucion de pixel (rejilla de 4 px interpolada)
	var S := 4
	var gw: int = W / S + 3
	var grid := PackedFloat32Array()
	grid.resize(gw * gw)
	var org: int = -span * T - T / 2
	var FS: float = 6.0 * float(T)
	for j in range(gw):
		for i in range(gw):
			grid[j * gw + i] = fbm(float(org + (i - 1) * S) / FS, float(org + (j - 1) * S) / FS, seed_v + 303)
		if step and Time.get_ticks_usec() - t0 > SLICE_USEC:
			await tree.process_frame
			if _bake_abort:
				return
			t0 = Time.get_ticks_usec()
	var mask := PackedByteArray()
	mask.resize(W * (W + 1))
	for y in range(-1, W):
		var fy: float = float(y + S) / float(S)
		var jj: int = int(fy)
		var v: float = fy - float(jj)
		for x in range(W):
			var fx: float = float(x + S) / float(S)
			var ii: int = int(fx)
			var u: float = fx - float(ii)
			var a: float = grid[jj * gw + ii]
			var b: float = grid[jj * gw + ii + 1]
			var c: float = grid[(jj + 1) * gw + ii]
			var d: float = grid[(jj + 1) * gw + ii + 1]
			var val: float = (a + (b - a) * u) * (1.0 - v) + (c + (d - c) * u) * v
			val += (hsh((org + x) >> 1, (org + y) >> 1, seed_v + 9) - 0.5) * 0.05
			mask[(y + 1) * W + x] = 1 if val > 0.64 else 0
		if step and Time.get_ticks_usec() - t0 > SLICE_USEC:
			await tree.process_frame
			if _bake_abort:
				return
			t0 = Time.get_ticks_usec()
	liquid_tiles.clear()
	for j in range(n):
		for i in range(n):
			var tx: int = i - span
			var ty: int = j - span
			var kind: int = terrain(tx, ty)
			if kind == VOID:
				continue
			_paint_floor(P, C, i * T, j * T, tx, ty, mask, W)
			if kind == WALL:
				_paint_wall(P, C, i * T, j * T, tx, ty)
			elif kind == LIQUID:
				_paint_liquid(P, C, i * T, j * T, tx, ty)
				liquid_tiles.append(Vector2i(tx, ty))
			if step and Time.get_ticks_usec() - t0 > SLICE_USEC:
				await tree.process_frame
				if _bake_abort:
					return
				t0 = Time.get_ticks_usec()
	baked_img = P.img()
	_bake_props()


func _paint_floor(P: Pix, C: Dictionary, ox: int, oy: int, tx: int, ty: int, mask: PackedByteArray, W: int) -> void:
	var dirt_count := 0
	var fl: Array = C["floor"]
	var dt: Array = C["dirt"]
	for y in range(T):
		for x in range(T):
			var gx: int = tx * T + x
			var gy: int = ty * T + y
			var lx: int = ox + x
			var ly: int = oy + y
			var dirt: bool = mask[(ly + 1) * W + lx] == 1
			var up: bool = mask[ly * W + lx] == 1
			if dirt:
				dirt_count += 1
			var pal: Array = dt if dirt else fl
			var band: float = hsh(gx >> 3, gy >> 3, 11) * 0.7 + hsh(gx, gy, 12) * 0.5
			var col: int = pal[mini(pal.size() - 1, int(floorf(band * float(pal.size()) / 1.2)))]
			var rr: float = hsh(gx, gy, 13)
			if rr < 0.035:
				col = C["speck"]
			elif rr > 0.985:
				col = C["light"]
			if dirt and not up:
				col = C["speck"]
			elif not dirt and up and rr < 0.5:
				col = C["light"]
			P.set_px(ox + x, oy + y, col)
	var is_dirt: bool = dirt_count > T * T / 2
	if _at(tx, ty - 1) == WALL:
		for x in range(T):
			P.set_px(ox + x, oy, C["wallFaceDark"])
			if (x + ty) % 2 != 0:
				P.set_px(ox + x, oy + 1, C["speck"])
	var d: float = hsh(tx, ty, 14)
	var dx: int = ox + 3 + int(hsh(tx, ty, 15) * 10.0)
	var dy: int = oy + 4 + int(hsh(tx, ty, 16) * 9.0)
	var lt: int = C["light"]
	var sp: int = C["speck"]
	if is_dirt:
		if d < 0.22:
			P.set_px(dx, dy, lt)
			P.set_px(dx + 1, dy, lt)
			P.set_px(dx, dy + 1, sp)
			P.set_px(dx + 1, dy + 1, sp)
		return
	if d < 0.18:
		P.set_px(dx, dy, lt)
		P.set_px(dx - 1, dy - 1, lt)
		P.set_px(dx + 1, dy - 1, lt)
		P.set_px(dx, dy - 2, lt)
		P.set_px(dx, dy + 1, sp)
	elif d < 0.26:
		var fls: Array = C["flowers"]
		var fc: int = fls[int(hsh(tx, ty, 17) * float(fls.size()))]
		P.set_px(dx, dy - 1, fc)
		P.set_px(dx - 1, dy, fc)
		P.set_px(dx + 1, dy, fc)
		P.set_px(dx, dy + 1, fc)
		P.set_px(dx, dy, lt)
	elif d < 0.32:
		P.set_px(dx, dy, lt)
		P.set_px(dx + 1, dy, lt)
		P.set_px(dx, dy + 1, sp)
		P.set_px(dx + 1, dy + 1, sp)


func _paint_wall(P: Pix, C: Dictionary, ox: int, oy: int, tx: int, ty: int) -> void:
	var n: bool = _at(tx, ty - 1) == WALL
	var s: bool = _at(tx, ty + 1) == WALL
	var w: bool = _at(tx - 1, ty) == WALL
	var e: bool = _at(tx + 1, ty) == WALL
	var face: int = 0 if s else 6
	var tops: Array = C["wallTop"]
	var faces: Array = C["wallFace"]
	for y in range(T):
		for x in range(T):
			if not n and not w and x + y < 3:
				continue
			if not n and not e and (T - 1 - x) + y < 3:
				continue
			if not s and not w and x + (T - 1 - y) < 2:
				continue
			if not s and not e and (T - 1 - x) + (T - 1 - y) < 2:
				continue
			var gx: int = tx * T + x
			var gy: int = ty * T + y
			var col: int
			if y >= T - face:
				var fy: int = y - (T - face)
				var vv: int = 0 if hsh(gx, 0, 21) < 0.5 else 1
				col = faces[1 if (x + vv) % 3 == 0 else 0]
				if fy == 0:
					col = C["wallEdge"]
				elif y == T - 1:
					col = C["wallFaceDark"]
				elif hsh(gx, gy, 22) < 0.08:
					col = C["wallFaceDark"]
			else:
				col = tops[int(hsh(gx >> 1, gy >> 1, 23) * 2.2 + hsh(gx, gy, 24) * 0.8) % tops.size()]
				if hsh(gx, gy, 25) < 0.05:
					col = C["wallLight"]
				if not n and y == 0:
					col = C["wallEdge"]
				elif not n and y == 1:
					col = C["wallLight"]
				if not w and x == 0:
					col = C["wallEdge"]
				if not e and x == T - 1:
					col = C["wallEdge"]
			P.set_px(ox + x, oy + y, col)


func _paint_liquid(P: Pix, C: Dictionary, ox: int, oy: int, tx: int, ty: int) -> void:
	var n: bool = _at(tx, ty - 1) == LIQUID
	var s: bool = _at(tx, ty + 1) == LIQUID
	var w: bool = _at(tx - 1, ty) == LIQUID
	var e: bool = _at(tx + 1, ty) == LIQUID
	var nw: bool = _at(tx - 1, ty - 1) == LIQUID
	var ne: bool = _at(tx + 1, ty - 1) == LIQUID
	var sw: bool = _at(tx - 1, ty + 1) == LIQUID
	var se: bool = _at(tx + 1, ty + 1) == LIQUID
	var BIG := 99.0
	for y in range(T):
		for x in range(T):
			if not n and not w and x + y < 3:
				continue
			if not n and not e and (T - 1 - x) + y < 3:
				continue
			if not s and not w and x + (T - 1 - y) < 3:
				continue
			if not s and not e and (T - 1 - x) + (T - 1 - y) < 3:
				continue
			var d: float = minf(minf(BIG if n else float(y), BIG if s else float(T - 1 - y)), minf(BIG if w else float(x), BIG if e else float(T - 1 - x)))
			if n and w and not nw:
				d = minf(d, Vector2(x, y).length() - 0.5)
			if n and e and not ne:
				d = minf(d, Vector2(T - 1 - x, y).length() - 0.5)
			if s and w and not sw:
				d = minf(d, Vector2(x, T - 1 - y).length() - 0.5)
			if s and e and not se:
				d = minf(d, Vector2(T - 1 - x, T - 1 - y).length() - 0.5)
			var gx: int = tx * T + x
			var gy: int = ty * T + y
			var rr: float = hsh(gx, gy, 31)
			var col: int
			if d < 1.0:
				col = C["shore"]
			elif d < 2.0:
				col = C["foam"]
			elif d < 4.0:
				col = C["liqLight"]
			elif d < 6.0:
				col = C["liq"] if rr < 0.5 else C["liqLight"]
			else:
				col = C["liq"] if (d < 8.0 and rr < 0.5) else C["liqDeep"]
			if d >= 6.0 and d < BIG and rr < 0.08:
				col = C["liq"]
			if d >= 3.0 and hsh(gx >> 2, gy, 33) < 0.045 and (gx & 3) != 3:
				col = C["liqLight"]
			if d >= 3.0 and hsh(gx, gy, 34) < 0.004:
				col = C["foam"]
			P.set_px(ox + x, oy + y, col)


# --- sprites de objetos (tiles.js PAINT) ---
func _bake_props() -> void:
	var style: String = String(th.get("prop", "tree"))
	for tv in range(3):
		prop_imgs["tree" + str(tv)] = _paint_tree(style, tv)
	prop_imgs["tree"] = prop_imgs["tree0"]
	prop_imgs["rock0"] = _paint_rock(0)
	prop_imgs["rock1"] = _paint_rock(1)
	prop_imgs["grass0"] = _paint_grass(0)
	prop_imgs["grass1"] = _paint_grass(1)


func _cols(key: String) -> Array:
	var a: Array = []
	for c in palette[key]:
		a.append(pk(c))
	return a


func _paint_tree(style: String, tv: int = 0) -> Image:
	if style == "crystal":
		return _paint_crystal(tv)
	if style == "dead":
		return _paint_dead(tv)
	var P := Pix.new(30, 40)
	var L: Array = _cols("leaf")
	var Tr: Array = _cols("trunk")
	for y in range(26, 38):
		for x in range(13, 18):
			P.set_px(x, y, Tr[0 if (x == 13 or x == 17) else 1])
	P.set_px(12, 37, Tr[0])
	P.set_px(18, 37, Tr[0])
	P.set_px(11, 38, Tr[0])
	P.set_px(19, 38, Tr[0])
	var bi := 0
	for bl in [[15, 20, 10], [9, 16, 7], [21, 16, 7], [15, 10, 8], [10, 23, 6], [20, 23, 6]]:
		bi += 1
		var bx: int = bl[0]
		var by: int = bl[1]
		var br: int = bl[2]
		if tv > 0:
			bx += int(hsh(bi, tv, 301) * 3.0) - 1
			by += int(hsh(bi, tv, 302) * 3.0) - 1
			br += int(hsh(bi, tv, 303) * 3.0) - 1 if br > 6 else 0
		for y in range(by - br, by + br + 1):
			for x in range(bx - br, bx + br + 1):
				var d: float = Vector2(x - bx, y - by).length()
				if d <= float(br):
					var lit: float = (float(x - bx) * -0.6 + float(y - by) * -0.8) / float(br)
					var idx: int = 3 if lit > 0.45 else (2 if lit > 0.05 else (1 if lit > -0.45 else 0))
					P.set_px(x, y, L[idx - 1] if (hsh(x, y, 41) < 0.12 and idx > 0) else L[idx])
	P.outline(pk(Color("#14200f")))
	return P.img()


func _paint_crystal(tv: int = 0) -> Image:
	var P := Pix.new(26, 40)
	var L: Array = _cols("leaf")
	var D: Array = _cols("trunk")
	var spires: Array = [[13, 2, 5, 38], [7, 14, 4, 38], [19, 12, 4, 38]]
	if tv == 1:
		spires = [[13, 6, 5, 38], [6, 12, 4, 38], [20, 16, 3, 38], [10, 20, 3, 38]]
	elif tv == 2:
		spires = [[12, 4, 4, 38], [19, 10, 5, 38], [5, 18, 3, 38]]
	for sp in spires:
		var cx: int = sp[0]
		var top: int = sp[1]
		var half: int = sp[2]
		var bot: int = sp[3]
		for y in range(top, bot + 1):
			var t: float = minf(1.0, float(y - top) / 8.0)
			var hw: int = int(roundf(float(half) * t))
			for x in range(cx - hw, cx + hw + 1):
				var side: int = (3 if x == cx - hw else 2) if x < cx else (1 if x == cx else 0)
				P.set_px(x, y, L[side] if side >= 2 else (D[1] if y > bot - 4 else L[side]))
	P.outline(D[0])
	return P.img()


func _paint_dead(tv: int = 0) -> Image:
	var P := Pix.new(28, 40)
	var Tr: Array = _cols("trunk")
	var L: Array = _cols("leaf")
	for y in range(12 + tv * 2, 38):
		for x in range(12, 16):
			P.set_px(x, y, Tr[0 if x < 14 else 1])
	var brs: Array = [[12, 20, -1, 9], [15, 17, 1, 10], [13, 13, -1, 7], [14, 12, 1, 6]]
	if tv == 1:
		brs = [[12, 24, -1, 10], [15, 20, 1, 8], [13, 16, -1, 6], [14, 15, 1, 9]]
	elif tv == 2:
		brs = [[12, 22, -1, 7], [15, 25, 1, 11], [13, 17, 1, 6], [14, 16, -1, 8]]
	for br in brs:
		for i in range(int(br[3])):
			P.set_px(int(br[0]) + int(br[2]) * i, int(br[1]) - i, L[1])
			P.set_px(int(br[0]) + int(br[2]) * i, int(br[1]) - i + 1, L[0])
	P.outline(pk(Color("#0f0b09")))
	return P.img()


func _paint_rock(variant: int) -> Image:
	var P := Pix.new(22, 17)
	var R: Array = _cols("rock")
	var shine: int = pk(Color.WHITE)
	for y in range(2, 16):
		for x in range(1, 21):
			var nx: float = (float(x) - 10.5) / 9.5
			var ny: float = (float(y) - 9.5) / 7.0
			var d: float = nx * nx + ny * ny + (hsh(x, y, 61) - 0.5) * 0.08
			if d > 1.0:
				continue
			var lit: float = -nx * 0.55 - ny * 0.85 + (hsh(x, y, 62) - 0.5) * 0.25
			var c: int = R[2 if lit > 0.4 else (1 if lit > -0.15 else 0)]
			if y >= 14:
				c = R[0]
			P.set_px(x, y, c)
	for p in [[6, 5], [7, 5], [6, 6], [8, 4]]:
		P.set_px(p[0], p[1], shine)
	for p in [[13, 8], [14, 9], [9, 11], [16, 11], [11, 7]]:
		P.set_px(p[0], p[1], R[0])
	if variant == 1:
		var dark: int = pk(Color("#1b1d22"))
		for p in [[9, 4], [10, 5], [10, 6], [11, 7], [10, 8], [12, 8], [13, 9], [8, 9], [7, 10]]:
			P.set_px(p[0], p[1], dark)
	P.outline(pk(Color("#17191d")))
	return P.img()


func _paint_grass(variant: int) -> Image:
	var P := Pix.new(20, 17)
	var G3: Array = _cols("grass")
	var dark: int = pk(palette["speck"])
	var sway: float = 1.2 if variant == 1 else 0.0
	var blades := 11
	for pass_i in range(2):
		var b: int = pass_i
		while b < blades:
			var t: float = float(b) / float(blades - 1)
			var x0: float = 3.0 + t * 13.0 + (hsh(b, 7, 52) - 0.5) * 2.0
			var hgt: int = 8 + int(hsh(b, 3, 51) * 6.0) + (3 if absf(t - 0.5) < 0.25 else 0)
			var lean: float = (t - 0.5) * 7.0 + sway * (0.6 + hsh(b, 1, 53))
			for i in range(hgt + 1):
				var k: float = float(i) / float(hgt)
				var x: int = int(roundf(x0 + lean * k * k))
				var y: int = 16 - i
				var c: int = G3[2] if k > 0.78 else (G3[1] if k > 0.25 else G3[0])
				if pass_i == 0 and k <= 0.78:
					c = G3[0]
				P.set_px(x, y, c)
				if float(i) < float(hgt) * 0.45:
					P.set_px(x + 1, y, dark if k < 0.15 else G3[0])
			b += 2
	P.outline(pk(Color("#0e1d0c")))
	return P.img()


# ---------------------------------------------------------------
# Escena: suelo horneado + decoracion + brillo de liquidos
# ---------------------------------------------------------------
func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


func _draw() -> void:
	if palette.is_empty():
		return
	var span: int = int(r) + OUTER
	var big: float = float(span + 8) * TS
	draw_rect(Rect2(Vector2(-big, -big), Vector2(big * 2.0, big * 2.0)), palette["bg"])
	if tex != null:
		var o := Vector2(-(float(span) + 0.5) * TS, -(float(span) + 0.5) * TS)
		draw_texture_rect(tex, Rect2(o, Vector2(tex.get_width(), tex.get_height()) * PX), false)


func build(world_node: Node2D) -> void:
	if _built:
		return
	_built = true
	finish_bake()
	queue_redraw()
	var lf := LiquidFx.new()
	lf.arena = self
	add_child(lf)
	var span: int = int(r) + OUTER
	var pr: Dictionary = th.get("props", {})
	var ptree: float = float(pr.get("tree", 0.0))
	var prock: float = float(pr.get("rock", 0.0))
	var pgrass: float = float(pr.get("grass", 0.0))
	for ly in range(-span, span + 1):
		for lx in range(-span, span + 1):
			if terrain(lx, ly) != FLOOR:
				continue
			var ad: float = Vector2(lx, ly).length()
			if ad >= r - 1.2 or _safe(lx, ly):
				continue
			var open := true
			for b in range(-1, 2):
				for a in range(-1, 2):
					if terrain(lx + a, ly + b) != FLOOR:
						open = false
			var hh: float = hsh(lx, ly, seed_v + 777)
			var kind := ""
			if open and hh < ptree:
				kind = "tree"
			elif open and hh < ptree + prock:
				kind = "rock"
			elif hh > 1.0 - pgrass:
				kind = "grass"
			if kind != "":
				var p := ArenaProp.new()
				p.setup(kind, self, hsh(lx, ly, seed_v + 5))
				p.position = global_position + Vector2(float(lx) * TS, float(ly) * TS + TS * 0.35)
				world_node.add_child(p)
				prop_nodes.append(p)
				if kind != "grass":
					solids.append([p.position, 15.0 if kind == "tree" else 18.0])


func clear_props() -> void:
	for p in prop_nodes:
		if is_instance_valid(p):
			p.queue_free()
	prop_nodes.clear()
	solids.clear()


class LiquidFx extends Node2D:
	var arena: Node2D
	var t := 0.0

	func _process(delta: float) -> void:
		t += delta
		queue_redraw()

	func _draw() -> void:
		var a = arena
		if a == null:
			return
		var kind: String = a.liquid_kind()
		var lava: bool = kind == "lava" or kind == "poison" or kind == "spark"
		var foam: Color = a.palette["foam"]
		var cam: Camera2D = get_viewport().get_camera_2d()
		var cp: Vector2 = cam.get_screen_center_position() - a.global_position if cam != null else Vector2.ZERO
		for tl in a.liquid_tiles:
			var pos := Vector2(float(tl.x) * a.TS, float(tl.y) * a.TS)
			if absf(pos.x - cp.x) > 760.0 or absf(pos.y - cp.y) > 460.0:
				continue
			var ph: float = a.hsh(tl.x, tl.y, 77) * TAU
			var k: float = (sin(t * (2.2 if lava else 1.6) + ph) + 1.0) * 0.5
			var c := foam
			c.a = (0.35 + k * 0.5) if lava else k * 0.7
			var sx: float = pos.x - 24.0 + floorf(a.hsh(tl.x, tl.y, 78) * 12.0 + 2.0) * 3.0
			var sy: float = pos.y - 24.0 + floorf(a.hsh(tl.x, tl.y, 79) * 12.0 + 2.0) * 3.0
			draw_rect(Rect2(sx + roundf(k * 2.0) * 3.0, sy, 6.0 if lava else 9.0, 3.0), c)
			if lava and k > 0.8:
				draw_rect(Rect2(sx, sy - 6.0, 3.0, 3.0), c)


class ArenaProp extends Node2D:
	var kind := "tree"
	var arena: Node2D
	var v := 0.5
	var wig := 0.0
	var gv := 0
	var t0 := 0.0

	func setup(k: String, ar: Node2D, vv: float) -> void:
		kind = k
		arena = ar
		v = vv
		wig = vv * 6.28
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		set_process(k == "grass")

	func _process(delta: float) -> void:
		t0 += delta
		var nv: int = 1 if sin(t0 * 2.4 + wig) > 0.55 else 0
		if nv != gv:
			gv = nv
			queue_redraw()

	func _draw() -> void:
		var key: String = "tree"
		if kind == "rock":
			key = "rock" + str(1 if v > 0.8 else 0)
		elif kind == "grass":
			key = "grass" + str(gv)
		var tx: Texture2D = arena.prop_texs.get(key)
		if tx == null:
			return
		if kind != "grass":
			draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.36))
			draw_circle(Vector2.ZERO, 19.0 if kind == "tree" else 22.0, Color(0, 0, 0, 0.3))
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		var sz := Vector2(tx.get_width(), tx.get_height()) * 3.0
		draw_texture_rect(tx, Rect2(Vector2(-sz.x * 0.5, -sz.y + 6.0), sz), false)


# ---------------------------------------------------------------
# La grieta (portal animado del mapa): remolino, chispas, ondas y pulso
# ---------------------------------------------------------------
class Portal extends Node2D:
	const NF := 12
	const FW := 36
	const FH := 56
	static var frames: Array = []
	var t := 0.0
	var ttl := 45.0
	var sparks: Array = []
	var seed_r := randf() * 100.0

	static func build_frames() -> void:
		if not frames.is_empty():
			return
		var glow: int = ArenaScript.pk(Color("#7b3cff"))
		var glow2: int = ArenaScript.pk(Color("#5a2bd0"))
		var mid: int = ArenaScript.pk(Color("#b48aff"))
		var mid2: int = ArenaScript.pk(Color("#9a66ff"))
		var core: int = ArenaScript.pk(Color("#140a26"))
		var core2: int = ArenaScript.pk(Color("#2a1550"))
		var white: int = ArenaScript.pk(Color("#f2e6ff"))
		var pink: int = ArenaScript.pk(Color("#e6c8ff"))
		for k in range(NF):
			var ph: float = float(k) / float(NF) * TAU
			var P := ArenaScript.Pix.new(FW, FH)
			for y in range(2, FH - 2):
				var tt: float = float(y - 2) / float(FH - 5)
				var w: float = sin(tt * PI) * 11.0 + 1.0
				var off: int = int(roundf(sin(tt * 9.0 + ph) * 2.2 + sin(tt * 4.0 - ph * 2.0) * 1.2 + (ArenaScript.hsh(y, k, 91) - 0.5) * 1.6))
				for x in range(-int(ceilf(w)) - 4, int(ceilf(w)) + 5):
					var ax: float = absf(float(x)) / w
					var px: int = 18 + x + off
					if ax <= 0.5:
						var ang: float = atan2(float(y) - 28.0, float(x))
						var s: float = sin(ang * 2.0 + Vector2(x, y - 28).length() * 0.55 - ph * 2.0)
						var col: int = core2 if s > 0.5 else core
						if ArenaScript.hsh(px, y, 96 + (k % 3)) < 0.035:
							col = white
						P.set_px(px, y, col)
					elif ax <= 0.82:
						var s2: float = sin(tt * 15.0 - ph * 3.0 + float(x) * 0.35)
						var col2: int = mid if s2 > 0.1 else mid2
						if ArenaScript.hsh(px, y, 92 + k) < 0.13:
							col2 = white if ArenaScript.hsh(px, y, 97) < 0.5 else pink
						P.set_px(px, y, col2)
					elif ax <= 1.2 or ArenaScript.hsh(px, y, 93 + k) < 0.32:
						P.set_px(px, y, glow)
					elif ax <= 1.7 and ArenaScript.hsh(px, y, 98 + k) < 0.14:
						P.set_px(px, y, glow2)
			for i in range(8):
				P.set_px(15 + int(ArenaScript.hsh(i, k, 94) * 7.0), 8 + int(ArenaScript.hsh(i, k, 95) * 38.0), white)
			frames.append(ImageTexture.create_from_image(P.img()))

	func _init() -> void:
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		build_frames()

	func _process(delta: float) -> void:
		t += delta
		ttl -= delta
		if randf() < delta * 14.0:
			sparks.append({"p": Vector2(randf_range(-16.0, 16.0), -randf_range(10.0, 60.0)), "v": Vector2(randf_range(-10.0, 10.0), -randf_range(30.0, 70.0)), "l": randf_range(0.7, 1.4), "a": 0.0})
		for sp in sparks:
			sp["a"] = float(sp["a"]) + delta
			sp["p"] = (sp["p"] as Vector2) + (sp["v"] as Vector2) * delta
		sparks = sparks.filter(func(s): return float(s["a"]) < float(s["l"]))
		queue_redraw()

	func _draw() -> void:
		var open: float = clampf(t / 0.8, 0.0, 1.0)
		open = 1.0 - pow(1.0 - open, 3.0)
		var fo: float = minf(1.0, maxf(ttl, 0.0) / 1.5)
		var a: float = minf(1.0, t * 2.5) * fo
		var beat: float = 0.5 + 0.5 * sin(t * 4.0 + seed_r)
		# luz en el suelo: halo que late y dos ondas que se expanden
		draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.33))
		for i in range(4):
			draw_circle(Vector2.ZERO, 62.0 - float(i) * 11.0 + beat * 4.0, Color(0.5, 0.25, 1.0, (0.07 + 0.05 * float(i)) * a * open))
		for i in range(2):
			var rp: float = fmod(t * 0.7 + float(i) * 0.5, 1.0)
			draw_arc(Vector2.ZERO, 14.0 + rp * 62.0, 0.0, TAU, 40, Color(0.78, 0.6, 1.0, (1.0 - rp) * 0.55 * a * open), 3.0)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		# rayos de luz detras del portal (parpadean)
		for i in range(5):
			var ang: float = -PI * 0.5 + (float(i) - 2.0) * 0.28 + sin(t * 1.3 + float(i)) * 0.06
			var ln: float = (70.0 + 30.0 * sin(t * 2.1 + float(i) * 1.7)) * open
			draw_line(Vector2(0.0, -50.0), Vector2(0.0, -50.0) + Vector2.from_angle(ang) * ln, Color(0.7, 0.5, 1.0, 0.09 * a), 6.0)
		# el portal: cuadro animado, se abre desde el centro y respira
		var tx: Texture2D = frames[int(t * 12.0) % NF]
		var sz := Vector2(tx.get_width(), tx.get_height()) * 3.0
		var sy: float = (0.12 + 0.88 * open) * (1.0 + 0.025 * sin(t * 3.0))
		var h: float = sz.y * sy
		draw_texture_rect(tx, Rect2(Vector2(-sz.x * 0.5, -h + 12.0), Vector2(sz.x, h)), false, Color(1, 1, 1, a))
		# chispas que orbitan y chispas que suben
		for i in range(7):
			var oa: float = t * (1.6 + float(i % 3) * 0.4) + float(i) * 0.9
			var op := Vector2(cos(oa) * (30.0 + float(i % 2) * 8.0), -54.0 + sin(oa) * 52.0 * open)
			var front: bool = sin(oa) > -0.2
			draw_rect(Rect2(op - Vector2(1.5, 1.5), Vector2(3, 3)), Color(0.9, 0.82, 1.0, (0.9 if front else 0.4) * a))
		for sp in sparks:
			var k: float = float(sp["a"]) / float(sp["l"])
			var pp: Vector2 = sp["p"]
			draw_rect(Rect2(Vector2(roundf(pp.x / 3.0) * 3.0, roundf(pp.y / 3.0) * 3.0), Vector2(3, 3)), Color(0.85, 0.76, 1.0, (1.0 - k) * a))


const ArenaScript = preload("res://scripts/arena.gd")
