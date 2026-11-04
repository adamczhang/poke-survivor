extends RefCounted
# Fork SIMPLE MODE: route for click-to-move. A* over a small grid laid on top of whatever `free` says is
# walkable, so it needs no map data of its own and works the same outside, in rifts, caves and arenas.
# When the spot can't be reached it returns the way to the closest reachable point.

const CELL := 20.0
const PAD_CELLS := 18        # how far past the start and goal the route may wander
const MAX_EXPAND := 2500     # a click can land on a sealed-off spot; never flood the whole window
const MAX_USEC := 25000      # at most a dropped frame or two on a click; a slow device just searches less per click
const LINE_STEP := 12.0
const NBRS: Array[Vector2i] = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)]
const DIAG := 1.4142136

static var last_usec := 0    # how long the last route took, for playtests
static var last_expanded := 0
static var last_partial := false   # ran out of time before finishing: walk this far and search again


# Returns the waypoints to walk, without the start. Empty if there's nowhere closer to go.
static func find(from: Vector2, to: Vector2, free: Callable) -> Array:
	var t0: int = Time.get_ticks_usec()
	last_partial = false
	last_expanded = 0
	var out: Array = _route(from, to, free, t0)
	last_usec = Time.get_ticks_usec() - t0
	return out


static func _route(from: Vector2, to: Vector2, free: Callable, t0: int) -> Array:
	var memo := {}
	var ok := func(p: Vector2) -> bool:
		var k := Vector2i((p / 4.0).round())
		if not memo.has(k):
			memo[k] = bool(free.call(p))
		return bool(memo[k])
	var goal_free: bool = ok.call(to)
	if goal_free and _line_free(from, to, ok):
		return [to]   # nothing in the way: no search at all
	var start: Vector2i = _cell(from)
	if not ok.call(_center(start)):
		start = _near_free(start, ok)
		if start == Vector2i(2147483647, 0):
			return [to]   # standing somewhere the grid can't start from (deep in lava): just head there
	var goal: Vector2i = _cell(to)
	var lo := Vector2i(mini(start.x, goal.x) - PAD_CELLS, mini(start.y, goal.y) - PAD_CELLS)
	var hi := Vector2i(maxi(start.x, goal.x) + PAD_CELLS, maxi(start.y, goal.y) + PAD_CELLS)
	var g := {start: 0.0}
	var came := {}
	var closed := {}
	var heap: Array = []
	_push(heap, _h(start, goal), start)
	var best: Vector2i = start
	var best_h: float = _h(start, goal)
	var n := 0
	while not heap.is_empty():
		var c: Vector2i = _pop(heap)
		if closed.has(c):
			continue
		closed[c] = true
		var h: float = _h(c, goal)
		if h < best_h:
			best_h = h
			best = c
		if c == goal:
			break
		n += 1
		if n >= MAX_EXPAND or (n % 32 == 0 and Time.get_ticks_usec() - t0 > MAX_USEC):
			last_partial = true
			break
		var gc: float = float(g[c])
		for i in range(8):
			var d: Vector2i = NBRS[i]
			var q: Vector2i = c + d
			if q.x < lo.x or q.y < lo.y or q.x > hi.x or q.y > hi.y or closed.has(q):
				continue
			if not ok.call(_center(q)):
				continue
			if i >= 4 and not (ok.call(_center(Vector2i(c.x + d.x, c.y))) and ok.call(_center(Vector2i(c.x, c.y + d.y)))):
				continue   # no squeezing diagonally past a corner
			var ng: float = gc + (DIAG if i >= 4 else 1.0)
			if ng < float(g.get(q, INF)):
				g[q] = ng
				came[q] = c
				_push(heap, ng + _h(q, goal), q)
	last_expanded = n
	if best == start and start == _cell(from):
		return []
	var cells: Array = [best]
	while came.has(cells[-1]):
		cells.append(came[cells[-1]])
	cells.reverse()
	var pts: Array = [from]
	for c2 in cells:
		pts.append(_center(c2))
	if best == goal and goal_free and _line_free(pts[-1], to, ok):
		pts.append(to)
	return _smooth(pts, ok, t0)


# Cuts the staircase out of the grid path: keeps only the corners a straight walk can't skip.
static func _smooth(pts: Array, ok: Callable, t0: int) -> Array:
	var out: Array = []
	var i := 0
	var last: int = pts.size() - 1
	while i < last:
		var j: int = i + 1
		while j < last and j - i < 24 and Time.get_ticks_usec() - t0 < MAX_USEC + 8000 and _line_free(pts[i], pts[j + 1], ok):
			j += 1
		out.append(pts[j])
		i = j
	return out


static func _line_free(a: Vector2, b: Vector2, ok: Callable) -> bool:
	var d: float = a.distance_to(b)
	var n: int = ceili(d / LINE_STEP)
	for i in range(1, n + 1):
		if float(i) * LINE_STEP < LINE_STEP * 1.5:
			continue   # the hero may be hugging a wall where it starts
		if not ok.call(a.lerp(b, float(i) / float(n))):
			return false
	return true


static func _near_free(c: Vector2i, ok: Callable) -> Vector2i:
	for r in range(1, 4):
		for x in range(-r, r + 1):
			for y in range(-r, r + 1):
				if maxi(absi(x), absi(y)) == r and ok.call(_center(c + Vector2i(x, y))):
					return c + Vector2i(x, y)
	return Vector2i(2147483647, 0)


static func _cell(p: Vector2) -> Vector2i:
	return Vector2i(floori(p.x / CELL), floori(p.y / CELL))


static func _center(c: Vector2i) -> Vector2:
	return (Vector2(c) + Vector2(0.5, 0.5)) * CELL


static func _h(a: Vector2i, b: Vector2i) -> float:
	var dx: int = absi(a.x - b.x)
	var dy: int = absi(a.y - b.y)
	return float(maxi(dx, dy)) + (DIAG - 1.0) * float(mini(dx, dy))


static func _push(heap: Array, f: float, c: Vector2i) -> void:
	heap.append([f, c])
	var i: int = heap.size() - 1
	while i > 0:
		var p: int = (i - 1) / 2
		if float(heap[p][0]) <= float(heap[i][0]):
			break
		var t = heap[p]
		heap[p] = heap[i]
		heap[i] = t
		i = p


static func _pop(heap: Array) -> Vector2i:
	var top: Vector2i = heap[0][1]
	var tail = heap.pop_back()
	var n: int = heap.size()
	if n > 0:
		heap[0] = tail
		var i := 0
		while true:
			var a: int = i * 2 + 1
			var b: int = a + 1
			var m: int = i
			if a < n and float(heap[a][0]) < float(heap[m][0]):
				m = a
			if b < n and float(heap[b][0]) < float(heap[m][0]):
				m = b
			if m == i:
				break
			var t = heap[m]
			heap[m] = heap[i]
			heap[i] = t
			i = m
	return top
