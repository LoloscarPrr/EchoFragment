extends Control

signal restarted

@onready var ending_label: Label = $Panel/Margin/VBox/Ending
@onready var summary_label: Label = $Panel/Margin/VBox/Summary
@onready var details_label: Label = $Panel/Margin/VBox/Details
@onready var restart_button: Button = $Panel/Margin/VBox/Restart

func _ready() -> void:
	visible = false
	restart_button.pressed.connect(func() -> void:
		restarted.emit()
	)

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
	if world.has_flag(&"guardian_saved"):
		return "EL GUARDIÁN LIBERADO"
	if world.has_flag(&"guardian_remembers"):
		return "EL JURAMENTO RECORDADO"
	if world.has_flag(&"fragmented_knight_slain"):
		return "EL ÚLTIMO GOLPE"
	return "EL CAMINO INCONCLUSO"

func _summary_for(world: WorldState) -> String:
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

	return result
