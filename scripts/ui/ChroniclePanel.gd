class_name ChroniclePanel
extends Control

signal restarted

var ending_label: Label
var summary_label: Label
var details_label: Label
var restart_button: Button

func _ready() -> void:
	_build_ui()
	visible = false
	restart_button.pressed.connect(func() -> void:
		restarted.emit()
	)

func _build_ui() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.position = Vector2(-420, -300)
	panel.size = Vector2(840, 600)
	add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_bottom", 24)
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	margin.add_child(box)

	var title := Label.new()
	title.text = "LA CRÓNICA"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)

	ending_label = Label.new()
	ending_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(ending_label)

	summary_label = Label.new()
	summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(summary_label)

	details_label = Label.new()
	details_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(details_label)

	restart_button = Button.new()
	restart_button.text = "Comenzar otra aventura"
	restart_button.custom_minimum_size = Vector2(0, 52)
	box.add_child(restart_button)

func show_chronicle(world: WorldState, player) -> void:
	ending_label.text = _ending_for(world)
	summary_label.text = _summary_for(world)

	var decisions: Array[String] = _decisions_for(world)
	var weapon := String(player.inventory.equipped_weapon)
	var lines: Array[String] = []
	lines.append("Nivel alcanzado: %d" % player.progression.level)
	lines.append("Arma equipada al final: %s" % weapon)
	lines.append("")
	lines.append("Decisiones registradas:")
	for decision in decisions:
		lines.append("• " + decision)

	details_label.text = "\n".join(lines)
	visible = true

func _ending_for(world: WorldState) -> String:
	if world.has_flag(&"adventurer_fallen"):
		return "EL VIAJE TERMINA EN EL CAMINO"
	if world.has_flag(&"guardian_saved"):
		return "EL GUARDIÁN LIBERADO"
	if world.has_flag(&"guardian_remembers"):
		return "EL JURAMENTO RECORDADO"
	if world.has_flag(&"fragmented_knight_slain"):
		return "EL ÚLTIMO GOLPE"
	return "EL CAMINO INCONCLUSO"

func _summary_for(world: WorldState) -> String:
	if world.has_flag(&"adventurer_fallen"):
		return "La Crónica conserva tus decisiones aunque esta aventura no alcanzó las puertas de Valle Gris."
	if world.has_flag(&"guardian_saved"):
		return "Llegaste a Valle Gris después de romper la corrupción del antiguo guardián. Las runas del santuario cambiaron el destino del camino."
	if world.has_flag(&"guardian_remembers"):
		return "Llegaste a Valle Gris sin ejecutar al guardián. La carta sellada despertó un juramento que la corrupción no había borrado."
	if world.has_flag(&"fragmented_knight_slain"):
		return "Llegaste a Valle Gris después de derrotar al Caballero Fragmentado. El camino quedó abierto, pero algunas respuestas murieron con él."
	return "Tu aventura terminó antes de resolver el destino del camino."

func _decisions_for(world: WorldState) -> Array[String]:
	var result: Array[String] = []
	if world.has_flag(&"traveler_helped"):
		result.append("Ayudaste al viajero herido.")
	elif world.has_flag(&"traveler_abandoned"):
		result.append("Abandonaste al viajero.")
	elif world.has_flag(&"letter_taken"):
		result.append("Tomaste la carta sellada.")

	if world.has_flag(&"shrine_understood"):
		result.append("Comprendiste las runas del santuario.")
	elif world.has_flag(&"shrine_respected"):
		result.append("Respetaste el santuario.")
	elif world.has_flag(&"shrine_opened"):
		result.append("Forzaste la losa del santuario.")

	if world.has_flag(&"hidden_route_found"):
		result.append("Usaste una ruta oculta.")
	elif world.has_flag(&"passage_forced"):
		result.append("Abriste el paso por la fuerza.")

	if world.has_flag(&"guardian_saved"):
		result.append("Liberaste al Caballero Fragmentado.")
	elif world.has_flag(&"guardian_remembers"):
		result.append("Hiciste que recordara su juramento.")
	elif world.has_flag(&"fragmented_knight_slain"):
		result.append("Diste muerte al Caballero Fragmentado.")

	if result.is_empty():
		result.append("La aventura terminó antes de dejar una marca profunda.")

	return result
