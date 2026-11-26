# Kleine QR-code-generator (byte-modus, foutcorrectie M, versie 1 t/m 6).
# Genoeg voor een link van maximaal 106 tekens.
# Gebruik: var tex := QrCode.make_texture("https://...", 8)
extends RefCounted

# versie -> [totaal aantal codewoorden, ecc-codewoorden per blok, aantal blokken]  (niveau M)
const TABLE := {
	1: [26, 10, 1],
	2: [44, 16, 1],
	3: [70, 26, 1],
	4: [100, 18, 2],
	5: [134, 24, 2],
	6: [172, 16, 4],
}
const ALIGN := {2: 18, 3: 22, 4: 26, 5: 30, 6: 34}

var size := 0
var modules := []      # modules[y][x] = true is zwart
var is_func := []      # functie-patronen (finder, timing, ...)


## Geeft de matrix terug als Array van Arrays met bools, of [] als de tekst te lang is.
static func encode(text: String) -> Array:
	var qr = load("res://code/qr_code.gd").new()
	return qr._encode(text.to_utf8_buffer())


## Maakt een zwart-wit texture met een witte rand van 4 modules.
static func make_texture(text: String, scale: int = 8) -> ImageTexture:
	var m := encode(text)
	if m.is_empty():
		return null
	var n: int = m.size()
	var border := 4
	var px := (n + border * 2) * scale
	var img := Image.create(px, px, false, Image.FORMAT_RGB8)
	img.fill(Color.WHITE)
	for y in n:
		for x in n:
			if m[y][x]:
				img.fill_rect(Rect2i((x + border) * scale, (y + border) * scale, scale, scale), Color.BLACK)
	return ImageTexture.create_from_image(img)


func _encode(data: PackedByteArray) -> Array:
	var version := 0
	for v in range(1, 7):
		var data_cw: int = TABLE[v][0] - TABLE[v][1] * TABLE[v][2]
		if 4 + 8 + data.size() * 8 <= data_cw * 8:
			version = v
			break
	if version == 0:
		return []

	# --- bitstroom: modus 0100 (bytes), lengte (8 bits), data, afsluiter, opvulling
	var total: int = TABLE[version][0]
	var ecc_len: int = TABLE[version][1]
	var blocks: int = TABLE[version][2]
	var data_len: int = total - ecc_len * blocks
	var bits := []
	_append_bits(bits, 0x4, 4)
	_append_bits(bits, data.size(), 8)
	for b in data:
		_append_bits(bits, b, 8)
	_append_bits(bits, 0, mini(4, data_len * 8 - bits.size()))
	_append_bits(bits, 0, (8 - bits.size() % 8) % 8)
	var cw := PackedByteArray()
	for i in range(0, bits.size(), 8):
		var byte := 0
		for j in 8:
			byte = (byte << 1) | bits[i + j]
		cw.append(byte)
	var pad := 0xEC
	while cw.size() < data_len:
		cw.append(pad)
		pad = 0x11 if pad == 0xEC else 0xEC

	# --- foutcorrectie per blok en verweven (alle blokken zijn even lang bij niveau M, v1-6)
	@warning_ignore("integer_division")
	var per_block: int = data_len / blocks
	var divisor := _rs_divisor(ecc_len)
	var data_blocks := []
	var ecc_blocks := []
	for i in blocks:
		var blk := cw.slice(i * per_block, (i + 1) * per_block)
		data_blocks.append(blk)
		ecc_blocks.append(_rs_remainder(blk, divisor))
	var final := PackedByteArray()
	for i in per_block:
		for blk in data_blocks:
			final.append(blk[i])
	for i in ecc_len:
		for blk in ecc_blocks:
			final.append(blk[i])

	# --- matrix tekenen
	size = version * 4 + 17
	modules = []
	is_func = []
	for y in size:
		var row := []
		var frow := []
		row.resize(size)
		frow.resize(size)
		row.fill(false)
		frow.fill(false)
		modules.append(row)
		is_func.append(frow)

	for i in size:
		_set_func(6, i, i % 2 == 0)
		_set_func(i, 6, i % 2 == 0)
	_finder(3, 3)
	_finder(size - 4, 3)
	_finder(3, size - 4)
	if ALIGN.has(version):
		var p: int = ALIGN[version]
		for dy in range(-2, 3):
			for dx in range(-2, 3):
				_set_func(p + dx, p + dy, maxi(absi(dx), absi(dy)) != 1)
	_draw_format(0)  # reserveert de format-gebieden

	_draw_codewords(final)

	# --- beste masker kiezen
	var best := 0
	var best_pen := -1
	for mask in 8:
		_apply_mask(mask)
		_draw_format(mask)
		var pen := _penalty()
		if best_pen < 0 or pen < best_pen:
			best = mask
			best_pen = pen
		_apply_mask(mask)  # XOR nog een keer = ongedaan maken
	_apply_mask(best)
	_draw_format(best)
	return modules


func _append_bits(bits: Array, val: int, n: int) -> void:
	for i in range(n - 1, -1, -1):
		bits.append((val >> i) & 1)


func _set_func(x: int, y: int, dark: bool) -> void:
	modules[y][x] = dark
	is_func[y][x] = true


func _finder(cx: int, cy: int) -> void:
	for dy in range(-4, 5):
		for dx in range(-4, 5):
			var x := cx + dx
			var y := cy + dy
			if x >= 0 and x < size and y >= 0 and y < size:
				var d := maxi(absi(dx), absi(dy))
				_set_func(x, y, d != 2 and d != 4)


func _draw_format(mask: int) -> void:
	var data := (0 << 3) | mask  # niveau M = 00
	var rem := data
	for i in 10:
		rem = (rem << 1) ^ ((rem >> 9) * 0x537)
	var bits := ((data << 10) | rem) ^ 0x5412
	for i in range(0, 6):
		_set_func(8, i, _bit(bits, i))
	_set_func(8, 7, _bit(bits, 6))
	_set_func(8, 8, _bit(bits, 7))
	_set_func(7, 8, _bit(bits, 8))
	for i in range(9, 15):
		_set_func(14 - i, 8, _bit(bits, i))
	for i in range(0, 8):
		_set_func(size - 1 - i, 8, _bit(bits, i))
	for i in range(8, 15):
		_set_func(8, size - 15 + i, _bit(bits, i))
	_set_func(8, size - 8, true)


func _bit(val: int, i: int) -> bool:
	return ((val >> i) & 1) != 0


func _draw_codewords(data: PackedByteArray) -> void:
	var i := 0
	var right := size - 1
	while right >= 1:
		if right == 6:
			right = 5
		for vert in size:
			for j in 2:
				var x := right - j
				var upward := ((right + 1) & 2) == 0
				var y := (size - 1 - vert) if upward else vert
				if not is_func[y][x] and i < data.size() * 8:
					modules[y][x] = _bit(data[i >> 3], 7 - (i & 7))
					i += 1
		right -= 2


func _apply_mask(mask: int) -> void:
	for y in size:
		for x in size:
			if is_func[y][x]:
				continue
			var inv := false
			match mask:
				0: inv = (x + y) % 2 == 0
				1: inv = y % 2 == 0
				2: inv = x % 3 == 0
				3: inv = (x + y) % 3 == 0
				4: inv = (floori(x / 3.0) + floori(y / 2.0)) % 2 == 0
				5: inv = x * y % 2 + x * y % 3 == 0
				6: inv = (x * y % 2 + x * y % 3) % 2 == 0
				7: inv = ((x + y) % 2 + x * y % 3) % 2 == 0
			if inv:
				modules[y][x] = not modules[y][x]


# Vereenvoudigde strafpunten (regels 1, 2 en 4 van de QR-standaard) om een goed masker te kiezen.
func _penalty() -> int:
	var pen := 0
	for y in size:
		var run := 1
		for x in range(1, size + 1):
			if x < size and modules[y][x] == modules[y][x - 1]:
				run += 1
			else:
				if run >= 5:
					pen += run - 2
				run = 1
	for x in size:
		var run := 1
		for y in range(1, size + 1):
			if y < size and modules[y][x] == modules[y - 1][x]:
				run += 1
			else:
				if run >= 5:
					pen += run - 2
				run = 1
	var dark := 0
	for y in size - 1:
		for x in size - 1:
			var c: bool = modules[y][x]
			if c == modules[y][x + 1] and c == modules[y + 1][x] and c == modules[y + 1][x + 1]:
				pen += 3
	for y in size:
		for x in size:
			if modules[y][x]:
				dark += 1
	var total := size * size
	pen += floori(absi(dark * 20 - total * 10) / float(total)) * 10
	return pen


static func _gf_mul(x: int, y: int) -> int:
	var z := 0
	for i in range(7, -1, -1):
		z = (z << 1) ^ ((z >> 7) * 0x11D)
		z ^= ((y >> i) & 1) * x
	return z


static func _rs_divisor(degree: int) -> PackedByteArray:
	var result := PackedByteArray()
	result.resize(degree)
	result.fill(0)
	result[degree - 1] = 1
	var root := 1
	for i in degree:
		for j in degree:
			result[j] = _gf_mul(result[j], root)
			if j + 1 < degree:
				result[j] ^= result[j + 1]
		root = _gf_mul(root, 0x02)
	return result


static func _rs_remainder(data: PackedByteArray, divisor: PackedByteArray) -> PackedByteArray:
	var result := PackedByteArray()
	result.resize(divisor.size())
	result.fill(0)
	for b in data:
		var factor := b ^ result[0]
		result.remove_at(0)
		result.append(0)
		for i in result.size():
			result[i] ^= _gf_mul(divisor[i], factor)
	return result
