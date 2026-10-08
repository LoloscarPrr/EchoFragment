class_name SkillCatalog
extends RefCounted

const ORDER := [
	&"survival_breath",
	&"cunning_step",
	&"sword_riposte",
	&"bow_piercing",
	&"staff_overcharge",
	&"daggers_flurry"
]

const DATA := {
	&"survival_breath": {
		"name": "Aliento de superviviente",
		"branch": "Supervivencia",
		"description": "+20 aguante máximo y regeneración mejorada."
	},
	&"cunning_step": {
		"name": "Paso astuto",
		"branch": "Astucia",
		"description": "Esquivar cuesta menos aguante y dura un poco más."
	},
	&"sword_riposte": {
		"name": "Réplica",
		"branch": "Espada",
		"description": "El tercer golpe del combo de espada gana daño y retroceso."
	},
	&"bow_piercing": {
		"name": "Flecha perforante",
		"branch": "Arco",
		"description": "Las flechas infligen más daño y vuelan más rápido."
	},
	&"staff_overcharge": {
		"name": "Sobrecarga arcana",
		"branch": "Báculo",
		"description": "Los proyectiles arcanos ganan daño y empuje."
	},
	&"daggers_flurry": {
		"name": "Ráfaga de cuchillas",
		"branch": "Dagas",
		"description": "Las dagas cuestan menos aguante y aceleran el combo."
	}
}
