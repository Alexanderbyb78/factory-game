extends RefCounted
class_name belt_logic_reverse

var distances: PackedByteArray = PackedByteArray()
var item_ids: PackedByteArray = PackedByteArray()
var cashed_positions: PackedByteArray = PackedByteArray()

var B: int = 0
var A: int = 0
var L: int = 240
var item_size: int = 16
var focus : int = -1

var transfer_offset := 0
var next_belt : belt_logic_reverse = null

# IT LOOKS LIKE THIS:
#B ; distances.reversed() ; A
#|-- B --|-- Предмет 3 --|-- dist[2] --|-- Предмет 2 --|-- dist[1] --|-- Предмет 1 --|-- dist[0] --|-- Предмет 0 --|-- A --|

func _init(Length:int=240, size_of_item:int=16):
	L = Length
	item_size = size_of_item

func add_item(p:int=0, id:int=0) -> void:
	if p<0 or p>L: return
	if item_ids.is_empty():
		B = p; A = L-p; item_ids.append(id)
		if p==L: focus = 0; cashed_positions.append(p)
		return
	if p+item_size <= B:
		item_ids.append(id); distances.append(B-p); B = p
		if not cashed_positions.is_empty(): clean_focus()
		return
	if p-item_size >= L-A:
		item_ids.insert(0, id); distances.insert(0, p-(L-A)); A = L-p
		if p==L:
			focus = 0; cashed_positions.append(p); clean_focus()
		return
	if not cashed_positions.is_empty():
		if p+item_size > cashed_positions[-1]: return
		if p > cashed_positions[-1]/2.0:
			var bfr_p = cashed_positions[-1]
			var nxt_p = cashed_positions[-1]
			var idx = cashed_positions.size()-1
			var s = cashed_positions.size()-1
			for i in range(s, item_ids.size()-1):
				var d = distances[i]
				if nxt_p - d < p: bfr_p -= d; break
				bfr_p -= d; nxt_p -= d; idx += 1
			if p-item_size < bfr_p or p+item_size > nxt_p: return
			distances.set(idx, nxt_p - p)
			distances.insert(idx+1, p - bfr_p)
			item_ids.insert(idx+1, id)
			clean_focus()
			return
	if true:
		if p < L/2.0:
			var bfr_p = B
			var nxt_p = B
			var idx = distances.size()-1
			for i in range(distances.size()-1, -1, -1):
				var d = distances[i]
				if bfr_p + d > p: nxt_p += d; break
				bfr_p += d; nxt_p += d; idx -= 1
			if p-item_size < bfr_p or p+item_size > nxt_p: return
			distances.set(idx, nxt_p - p)
			distances.insert(idx+1, p - bfr_p)
			item_ids.insert(idx+1, id)
			return
		else:
			var bfr_p = L - A
			var nxt_p = L - A
			var idx = 0
			for d in distances:
				if nxt_p - d < p: bfr_p -= d; break
				bfr_p -= d; nxt_p -= d; idx += 1
			if p-item_size < bfr_p or p+item_size > nxt_p: return
			distances.set(idx, nxt_p - p)
			distances.insert(idx+1, p - bfr_p)
			item_ids.insert(idx+1, id)
			return

func move_tick() -> void:
	if item_ids.is_empty(): return
	var is_next = false
	if A <= 1 and next_belt and next_belt.can_add_item(transfer_offset):
		is_next = true
	if A > 0 and focus == -1:
		A -= 1; B += 1
		if A == 0:
			focus = 0; cashed_positions.append(L)
			if is_next:
				focus = -1
				next_belt.add_item(transfer_offset, item_ids[0])
				cashed_positions.clear()
				item_ids.remove_at(0)
				if item_ids.size() > 0:
					A += distances[0]
					distances.remove_at(0)
				else:
					A = 0; B = 0
	elif is_next:
		focus = -1
		next_belt.add_item(transfer_offset, item_ids[0])
		cashed_positions.clear()
		item_ids.remove_at(0)
		if item_ids.size() > 0:
			A += distances[0]
			distances.remove_at(0)
		else:
			A = 0; B = L
	elif item_ids.size() > 1:
		clean_focus()
		if focus < distances.size() and distances[focus] > item_size:
			distances[focus] -= 1
			B += 1
			if distances[focus] == item_size:
				cashed_positions.append(cashed_positions[-1] - distances[focus])
				focus += 1

func get_positions() -> PackedInt32Array:
	if item_ids.is_empty(): return PackedInt32Array()
	var pos = PackedInt32Array(); pos.resize(item_ids.size())
	if cashed_positions.is_empty():
		var p = L - A
		pos.set(0, p)
		var idx = 0
		for d in distances:
			p -= d; idx += 1; pos.set(idx, p)
		return pos
	else:
		var idx = 0
		for b in cashed_positions:
			pos.set(idx, b); idx += 1
		var s = cashed_positions.size() - 1
		var p = cashed_positions[-1]
		for i in range(s, item_ids.size()-1):
			p -= distances[i]
			pos.set(i+1, p)
		return pos

func can_add_item(p:int=0) -> bool:
	if p<0 or p>L: return false
	if item_ids.is_empty(): return true
	if p <= B:
		return p+item_size <= B
	if p >= L-A:
		return p-item_size >= L-A
	if not cashed_positions.is_empty():
		if p+item_size > cashed_positions[-1]: return false
		if p > cashed_positions[-1]/2.0:
			var bfr_p = cashed_positions[-1]
			var nxt_p = cashed_positions[-1]
			var s = cashed_positions.size()-1
			for i in range(s, item_ids.size()-1):
				var d = distances[i]
				if nxt_p - d < p: bfr_p -= d; break
				bfr_p -= d; nxt_p -= d
			return not (p-item_size < bfr_p or p+item_size > nxt_p)
	if true:
		if p < L/2.0:
			var bfr_p = B
			var nxt_p = B
			for i in range(distances.size()-1, -1, -1):
				var d = distances[i]
				if bfr_p + d > p: nxt_p += d; break
				bfr_p += d; nxt_p += d
			return not (p-item_size < bfr_p or p+item_size > nxt_p)
		else:
			var bfr_p = L - A
			var nxt_p = L - A
			for d in distances:
				if nxt_p - d < p: bfr_p -= d; break
				bfr_p -= d; nxt_p -= d
			return not (p-item_size < bfr_p or p+item_size > nxt_p)
	return false

func clean_focus():
	while focus < item_ids.size()-1 and distances[focus] == item_size:
		cashed_positions.append(cashed_positions[-1] - distances[focus])
		focus += 1
