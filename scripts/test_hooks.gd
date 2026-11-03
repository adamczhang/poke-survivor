extends Node
# Automated playtest hooks for the web build. Inert unless the export has the "testhooks" feature tag
# (only the "WebTest" preset sets it), so the published "Web" build never exposes any of this.
#
# In the browser it exposes window.pst:
#   pst.state()        -> JSON snapshot of the current scene (menu or run)
#   pst.ex("code")     -> evaluates a GDScript Expression with `main`, `menu`, `SV`, `hooks`, `tree` and returns JSON
#   pst.auto(on)       -> autoplay: wander in circles and pick a random card whenever a card screen is open
#   pst.log()          -> JSON list of events autoplay recorded (cards picked, stalls) since the last call

const SV = preload("res://scripts/save_data.gd")
const PG = preload("res://scripts/progress.gd")

var _cbs: Array = []          # JavaScriptBridge callbacks must stay referenced
var autoplay := false
var god := false
var events: Array = []
var _ang := 0.0
var _card_wait := 0.0
var _stall_t := 0.0
var _god_max := -1.0


func _ready() -> void:
	if not OS.has_feature("testhooks") or not OS.has_feature("web"):
		queue_free()
		return
	process_mode = Node.PROCESS_MODE_ALWAYS
	var api = JavaScriptBridge.create_object("Object")
	for pair in [["state", _js_state], ["ex", _js_ex], ["auto", _js_auto], ["log", _js_log], ["god", _js_god], ["speed", _js_speed]]:
		var cb = JavaScriptBridge.create_callback(pair[1])
		_cbs.append(cb)
		api[pair[0]] = cb
	JavaScriptBridge.get_interface("window").pst_raw = api
	_cbs.append(api)
	# callback return values do not reach JS, so each callback stores its result in window.pst_ret
	JavaScriptBridge.eval("""window.pst = {};
for (const k of ['state','ex','auto','log','god','speed']) window.pst[k] = (...a) => { window.pst_ret = null; window.pst_raw[k](...a); return window.pst_ret; };""", true)


func _main() -> Node:
	var cs: Node = get_tree().current_scene
	return cs if cs != null and cs.get("player") != null else null


func _menu() -> Node:
	var cs: Node = get_tree().current_scene
	return cs if cs != null and cs.get("main_btns") != null else null


func state() -> Dictionary:
	SV.ensure()
	var out := {"scene": "", "time_scale": Engine.time_scale, "simple": SV.simple(), "coins": int(SV.d.get("coins", 0)),
		"owned": SV.owned_count(), "selected": int(SV.d.get("selected", 0)), "autoplay": autoplay, "god": god}
	var cs: Node = get_tree().current_scene
	if cs != null:
		out["scene"] = String(cs.scene_file_path)
	var mn: Node = _menu()
	if mn != null:
		out["menu_screen"] = String(mn.get("cur"))
		var vis: Array = []
		for k in (mn.get("main_btns") as Dictionary).keys():
			if (mn.get("main_btns")[k] as Control).visible:
				vis.append(k)
		out["menu_buttons"] = vis
	var m: Node = _main()
	if m != null:
		var p = m.get("player")
		var mv: Array = []
		for x in p.moves:
			mv.append({"id": String(x["id"]), "kind": String(x["kind"]), "lvl": int(x.get("lvl", 1)), "evo": bool(x.get("evolved", false)), "fused": x.has("parts")})
		var cards = m.get("cards")
		var titles: Array = []
		if cards != null and cards.open:
			for it in cards.items:
				titles.append("%s:%s" % [String(it.get("cat", "")), String(it.get("id", it.get("title", "")))])
		out.merge({"mode": String(m.get("mode")), "run_time": snappedf(float(m.get("run_time")), 0.1), "level": int(p.level),
			"hp": snappedf(float(p.hp), 0.1), "max_hp": snappedf(float(p.max_hp), 0.1), "dead": bool(p.dead), "down": bool(m.get("down")),
			"choosing": bool(m.get("choosing")), "paused": bool(m.get("paused")), "pending_levels": int(m.get("pending_levels")),
			"cards_open": cards != null and cards.open, "cards": titles, "moves": mv, "slots": m.call("_slot_list").size(),
			"max_moves": m.call("_max_moves"), "cd_penalty": m.call("_simple_cd_penalty"), "bonds": int(m.get("bonds")),
			"in_arena": m.get("arena") != null, "rift_open": m.get("rift") != null, "boss_alive": m.call("_boss_alive"),
			"enemies": (m.get("enemies") as Array).size(), "dex": int(SV.run_dex)})
	return out


func _js_state(_args: Array) -> void:
	_ret(JSON.stringify(state()))


func _js_ex(args: Array) -> void:
	_ret(_ex(args))


func _ex(args: Array) -> String:
	var code := String(args[0]) if args.size() > 0 else ""
	var ex := Expression.new()
	var names := ["main", "menu", "SV", "hooks", "tree", "Engine", "PG"]
	var err := ex.parse(code, names)
	if err != OK:
		return JSON.stringify({"error": ex.get_error_text()})
	var res = ex.execute([_main(), _menu(), SV, self, get_tree(), Engine, PG], self, false)
	if ex.has_execute_failed():
		return JSON.stringify({"error": ex.get_error_text()})
	return JSON.stringify({"value": var_to_str(res) if not (res is String or res is int or res is float or res is bool or res == null) else res})


func _js_auto(args: Array) -> void:
	autoplay = bool(args[0]) if args.size() > 0 else true
	_ret(JSON.stringify({"autoplay": autoplay}))


func _js_god(args: Array) -> void:
	god = bool(args[0]) if args.size() > 0 else true
	var m: Node = _main()
	if not god and m != null and _god_max >= 0.0:
		var p = m.get("player")
		p.max_hp = _god_max
		p.hp = minf(p.hp, p.max_hp)
		_god_max = -1.0
	_ret(JSON.stringify({"god": god}))


func _js_speed(args: Array) -> void:
	var k: float = float(args[0]) if args.size() > 0 else 1.0
	if k == 1.0:
		Engine.remove_meta("test_speed")
	else:
		Engine.set_meta("test_speed", k)
	Engine.time_scale = k
	_ret(JSON.stringify({"speed": k}))


func _js_log(_args: Array) -> void:
	var e := events.duplicate()
	events.clear()
	_ret(JSON.stringify(e))


func _ret(s: String) -> void:
	JavaScriptBridge.get_interface("window").pst_ret = s


func _note(kind: String, info: Dictionary = {}) -> void:
	var m: Node = _main()
	var e := {"kind": kind, "t": snappedf(float(m.get("run_time")), 0.1) if m != null else -1.0}
	e.merge(info)
	events.append(e)
	if events.size() > 400:
		events.pop_front()


func _process(delta: float) -> void:
	var m: Node = _main()
	if m == null:
		return
	var p = m.get("player")
	if god and p != null and not p.dead:
		if _god_max < 0.0:
			_god_max = p.max_hp
		p.max_hp = 1.0e7   # heals clamp hp to max_hp, so max_hp itself has to be out of reach of one frame of damage
		p.hp = 1.0e7
		p.invuln = maxf(p.invuln, 0.5)
	elif not god and p != null and _god_max >= 0.0:
		p.max_hp = _god_max
		p.hp = minf(p.hp, p.max_hp)
		_god_max = -1.0
	if not autoplay:
		return
	var rd: float = delta / maxf(0.01, Engine.time_scale)   # real seconds
	# wander in a slow circle using the touch stick axis the game already reads
	_ang += rd * 0.7
	var stick = m.get("stick")
	if stick != null:
		stick.axis = Vector2.from_angle(_ang) * 0.9
	var cards = m.get("cards")
	if cards != null and cards.open:
		_card_wait += rd
		if _card_wait > 0.35 and cards.items.size() > 0:
			_card_wait = 0.0
			var i: int = randi() % cards.items.size()
			var it: Dictionary = cards.items[i]
			_note("pick", {"cat": String(it.get("cat", "")), "id": String(it.get("id", "")), "n": cards.items.size(), "head": String(cards.headline)})
			cards.chosen.emit(i)
		elif _card_wait > 3.0 and cards.items.size() == 0:
			_note("empty_cards", {"head": String(cards.headline)})
			_card_wait = 0.0
	else:
		_card_wait = 0.0
	# stall detector: "choosing" without any card screen means some other modal is waiting on the player
	if bool(m.get("choosing")) and not (cards != null and cards.open):
		_stall_t += rd
		if _stall_t > 5.0:
			_note("stall_choosing", {"paused": bool(m.get("paused"))})
			_stall_t = 0.0
	else:
		_stall_t = 0.0
