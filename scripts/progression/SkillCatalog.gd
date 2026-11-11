class_name SkillCatalog
extends RefCounted

# Four weapon trees: one root, two branches, and a final mastery node.
const BRANCHES := ["Supervivencia", "Arco", "Dagas", "Báculo", "Espada"]
const ORDER := [&"survival_breath", &"cunning_step", &"bow_piercing", &"bow_sweep", &"bow_quickdraw", &"bow_finisher", &"daggers_flurry", &"daggers_precision", &"daggers_lunge", &"daggers_execution", &"staff_overcharge", &"staff_focus", &"staff_channel", &"staff_echo", &"sword_riposte", &"sword_edge", &"sword_stagger", &"sword_finale"]
const DATA := {
	&"survival_breath": {"name": "Aliento de superviviente", "branch": "Supervivencia", "tier": 1, "description": "+20 aguante máximo y regeneración mejorada.", "requires": []},
	&"cunning_step": {"name": "Paso astuto", "branch": "Supervivencia", "tier": 1, "description": "Esquivar cuesta menos aguante y dura un poco más.", "requires": []},
	&"bow_piercing": {"name": "Flecha perforante", "branch": "Arco", "tier": 1, "description": "Los disparos ganan daño, velocidad y empuje.", "requires": []},
	&"bow_sweep": {"name": "Barrido de flecha", "branch": "Arco", "tier": 2, "description": "La flecha en mano y la patada amplían alcance, daño y empuje.", "requires": [&"bow_piercing"]},
	&"bow_quickdraw": {"name": "Tensado veloz", "branch": "Arco", "tier": 2, "description": "Disparas antes y recuperas el control más rápido.", "requires": [&"bow_piercing"]},
	&"bow_finisher": {"name": "Remate del cazador", "branch": "Arco", "tier": 3, "description": "La flecha final del combo cercano gana daño y velocidad.", "requires": [&"bow_sweep", &"bow_quickdraw"]},
	&"daggers_flurry": {"name": "Ráfaga de cuchillas", "branch": "Dagas", "tier": 1, "description": "Menor coste de aguante y ataques más rápidos.", "requires": []},
	&"daggers_precision": {"name": "Filo preciso", "branch": "Dagas", "tier": 2, "description": "Cada golpe cercano inflige +4 de daño.", "requires": [&"daggers_flurry"]},
	&"daggers_lunge": {"name": "Impulso sombrío", "branch": "Dagas", "tier": 2, "description": "Los ataques te impulsan ligeramente hacia delante.", "requires": [&"daggers_flurry"]},
	&"daggers_execution": {"name": "Cuarto filo", "branch": "Dagas", "tier": 3, "description": "El cuarto golpe del combo gana +8 de daño.", "requires": [&"daggers_precision", &"daggers_lunge"]},
	&"staff_overcharge": {"name": "Sobrecarga arcana", "branch": "Báculo", "tier": 1, "description": "Los hechizos aumentan daño y empuje.", "requires": []},
	&"staff_focus": {"name": "Concentración", "branch": "Báculo", "tier": 2, "description": "Cada hechizo cuesta 6 puntos menos de aguante.", "requires": [&"staff_overcharge"]},
	&"staff_channel": {"name": "Canalización rápida", "branch": "Báculo", "tier": 2, "description": "Reduce la recuperación después de cada hechizo.", "requires": [&"staff_overcharge"]},
	&"staff_echo": {"name": "Eco arcano", "branch": "Báculo", "tier": 3, "description": "Hechizos de mayor daño, velocidad y retroceso.", "requires": [&"staff_focus", &"staff_channel"]},
	&"sword_riposte": {"name": "Réplica", "branch": "Espada", "tier": 1, "description": "El tercer espadazo gana daño y retroceso.", "requires": []},
	&"sword_edge": {"name": "Filo despierto", "branch": "Espada", "tier": 2, "description": "Cada espadazo inflige +4 de daño.", "requires": [&"sword_riposte"]},
	&"sword_stagger": {"name": "Peso carmesí", "branch": "Espada", "tier": 2, "description": "Todos los golpes empujan más a los enemigos.", "requires": [&"sword_riposte"]},
	&"sword_finale": {"name": "Corte definitivo", "branch": "Espada", "tier": 3, "description": "El tercer espadazo inflige 14 de daño adicionales.", "requires": [&"sword_edge", &"sword_stagger"]},
}

static func weapon_item(skill_id: StringName) -> StringName:
	if not DATA.has(skill_id):
		return &""
	match str(DATA[skill_id]["branch"]):
		"Arco":
			return &"hunter_bow"
		"Dagas":
			return &"shadow_daggers"
		"Báculo":
			return &"apprentice_staff"
		"Espada":
			return &"rusted_sword"
	return &""

static func missing_requirements(skill_id: StringName, learned: Array[StringName]) -> Array[StringName]:
	var missing: Array[StringName] = []
	if not DATA.has(skill_id):
		return missing
	for requirement in DATA[skill_id]["requires"]:
		if not learned.has(requirement):
			missing.append(requirement)
	return missing
