extends Control

const QuizData = preload("res://code/quiz_data.gd")
const QrCode = preload("res://code/qr_code.gd")

## Adres van de GitHub Page (met / aan het eind Rowan).
const SITE_URL := "https://shinyrezz.github.io/pws-quiz/"
const TIME_PER_QUESTION := 60.0
## Tekens voor de code (zonder 0/O en 1/I/L teggen verwarring(ja rowan dit is normaal)
const ALPHABET := "0123456789ABCDEFGHJKMNPQRSTVWXYZ"

const GREEN := Color(0, 1, 0)
const GREEN_DIM := Color(0, 0.6, 0)
const BG := Color(0.02, 0.05, 0.02)

var font: FontFile = preload("res://terminal 16 unicode.ttf")

var company := ""
var answers := []        # punten per vraag (0-3)
var timed_out := []      # true als de tijd op was
var order := []          # geschudde volgorde van de antwoorden per vraag
var index := 0
var time_left := 0.0
var running := false

var screen: VBoxContainer
var chapter_label: Label
var timer_label: Label
var timer_bar: ProgressBar
var question_label: Label
var option_buttons := []


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	theme = _make_theme()
	var bg := ColorRect.new()
	bg.color = BG
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 20)
	add_child(margin)
	screen = VBoxContainer.new()
	screen.add_theme_constant_override("separation", 8)
	margin.add_child(screen)
	_show_name_screen()


func _make_theme() -> Theme:
	var t := Theme.new()
	t.default_font = font
	t.default_font_size = 24
	t.set_color("font_color", "Label", GREEN)
	t.set_color("font_color", "Button", Color(0, 0.8745098, 0))
	t.set_color("font_focus_color", "Button", Color(0, 0.8745098, 0))
	t.set_color("font_hover_color", "Button", Color(0, 0.6039216, 0))
	t.set_color("font_pressed_color", "Button", Color(0, 0.7019608, 0))
	t.set_color("font_disabled_color", "Button", Color(0, 0.35, 0))
	t.set_color("font_color", "LineEdit", GREEN)
	return t


func _clear() -> void:
	for c in screen.get_children():
		c.queue_free()
	option_buttons.clear()


func _label(text: String, font_size: int = 24, color := GREEN) -> Label:
	var l := Label.new()
	l.text = text
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", color)
	return l


# ---------- 1. naam van het bedrijf ----------

func _show_name_screen() -> void:
	_clear()
	screen.add_child(_label("hoe heet je bedrijf?", 48))
	screen.add_child(_label("je begint een bedrijf met 2 vrienden.
bij elke vraag kies jij wat je doet (60 sec per vraag)", 24, GREEN_DIM))
	var input := LineEdit.new()
	input.placeholder_text = "Bijv. Bakkerij De Korst"
	input.max_length = 30
	input.add_theme_font_size_override("font_size", 32)
	screen.add_child(input)
	var go := Button.new()
	go.text = "start"
	go.add_theme_font_size_override("font_size", 32)
	go.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	screen.add_child(go)
	var start := func():
		company = input.text.strip_edges()
		_start_quiz()
	go.pressed.connect(start)
	input.text_submitted.connect(func(_t): start.call())
	input.grab_focus.call_deferred()


# ---------- 2. de vragen ----------

func _start_quiz() -> void:
	var n := QuizData.QUESTIONS.size()
	answers.resize(n)
	answers.fill(0)
	timed_out.resize(n)
	timed_out.fill(false)
	order.clear()
	for i in n:
		var o := [0, 1, 2, 3]
		o.shuffle()
		order.append(o)
	index = 0
	_show_question()


func _show_question() -> void:
	_clear()
	var item: Dictionary = QuizData.QUESTIONS[index]

	var top := HBoxContainer.new()
	chapter_label = _label("vraag %d: %s" % [index + 1, item.ch], 24, GREEN_DIM)
	chapter_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(chapter_label)
	timer_label = _label("tijd: 60", 32)
	timer_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	top.add_child(timer_label)
	screen.add_child(top)

	timer_bar = ProgressBar.new()
	timer_bar.max_value = TIME_PER_QUESTION
	timer_bar.show_percentage = false
	timer_bar.custom_minimum_size.y = 10
	screen.add_child(timer_bar)

	question_label = _label(item.q, 28)
	screen.add_child(question_label)

	for pos in 4:
		var pts: int = order[index][pos]
		var b := Button.new()
		b.text = "%s) %s" % ["abcd"[pos], item.o[pts]]
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.add_theme_font_size_override("font_size", 20)
		b.pressed.connect(_on_answer.bind(pts, b))
		screen.add_child(b)
		option_buttons.append(b)

	time_left = TIME_PER_QUESTION
	running = true


func _process(delta: float) -> void:
	if not running:
		return
	time_left -= delta
	timer_bar.value = maxf(time_left, 0.0)
	timer_label.text = "tijd: " + str(ceili(maxf(time_left, 0.0)))
	if time_left <= 10.0:
		timer_label.add_theme_color_override("font_color", Color(1, 0.3, 0.2))
	if time_left <= 0.0:
		running = false
		timed_out[index] = true
		answers[index] = 0
		question_label.text = "tijd is op!!"
		for b in option_buttons:
			b.disabled = true
		_next_after(1.2)


func _on_answer(pts: int, button: Button) -> void:
	if not running:
		return
	running = false
	answers[index] = pts
	for b in option_buttons:
		b.disabled = b != button
	button.add_theme_color_override("font_color", Color.WHITE)
	_next_after(0.4)


func _next_after(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
	index += 1
	if index < QuizData.QUESTIONS.size():
		_show_question()
	else:
		_show_result()


# ---------- 3. resultaat, code en QR ----------

func _score() -> int:
	var s := 0
	for a in answers:
		s += a
	return s


func _level(score: int) -> Dictionary:
	var lv: Dictionary = QuizData.LEVELS[0]
	for l in QuizData.LEVELS:
		if score >= l.min:
			lv = l
	return lv


## 15 antwoorden van 0-3 = 30 bits = 6 tekens, plus 1 controleteken.
func make_code() -> String:
	var value := 0
	for i in answers.size():
		value |= int(answers[i]) << (2 * i)
	var chars := ""
	for i in 6:
		chars = ALPHABET[value & 31] + chars
		value >>= 5
	var check := 0
	for i in 6:
		check += ALPHABET.find(chars[i]) * (i + 1)
	return chars + ALPHABET[check % 32]


func _story_url(code: String) -> String:
	var url := SITE_URL + code
	if company != "":
		var with_name := url + "?n=" + company.uri_encode()
		if with_name.to_utf8_buffer().size() <= 106:  # past nog in de QR-code
			url = with_name
	return url


func _show_result() -> void:
	_clear()
	var score := _score()
	var maxs := QuizData.QUESTIONS.size() * 3
	var lv := _level(score)
	var company_name := company if company != "" else "Je bedrijf"
	var code := make_code()
	var url := _story_url(code)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 40)
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	screen.add_child(row)

	var left := VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.add_theme_constant_override("separation", 12)
	row.add_child(left)
	left.add_child(_label("score: %d/%d" % [score, maxs], 48))
	left.add_child(_label(lv.pill, 24, GREEN_DIM))
	left.add_child(_label(String(lv.title).replace("[naam]", company_name), 32))
	left.add_child(_label(lv.text, 22, GREEN_DIM))
	var cijfer := snappedf(1.0 + 9.0 * score / maxs, 0.1)
	left.add_child(_label("cijfer: %s (gemiddeld is 7,1)" % str(cijfer).replace(".", ","), 22, GREEN_DIM))
	var outs := timed_out.count(true)
	if outs > 0:
		left.add_child(_label("%d keer was je tijd op" % outs, 22, GREEN_DIM))
	var again := Button.new()
	again.text = "opnieuw"
	again.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	again.pressed.connect(func():
		Global.sceneswitch = false   # anders verwijdert het startscherm zichzelf meteen
		Global.sceneswitch2 = false
		get_tree().change_scene_to_file("res://node_2d.tscn"))
	left.add_child(again)

	var right := VBoxContainer.new()
	right.custom_minimum_size.x = 400
	right.add_theme_constant_override("separation", 8)
	row.add_child(right)
	var head := _label("scan voor je verhaal:", 24)
	head.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	right.add_child(head)
	var qr := TextureRect.new()
	qr.texture = QrCode.make_texture(url, 6)
	qr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	qr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	qr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	qr.custom_minimum_size = Vector2(300, 300)
	right.add_child(qr)
	var pretty := code.substr(0, 3) + "-" + code.substr(3)
	var code_label := _label("code: " + pretty, 32)
	code_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	right.add_child(code_label)
	var link := _label(SITE_URL.replace("https://", ""), 20, GREEN_DIM)
	link.autowrap_mode = TextServer.AUTOWRAP_OFF
	link.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	right.add_child(link)
	print("Verhaal-link: ", url)
