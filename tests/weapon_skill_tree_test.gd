extends SceneTree

func _initialize() -> void:
	var progress := Progression.new()
	progress.skill_points = 20
	assert(not progress.can_unlock(&"not_a_skill"))
	assert(not progress.can_unlock(&"bow_finisher"))
	assert(progress.can_unlock(&"bow_piercing"))
	assert(progress.unlock(&"bow_piercing"))
	assert(not progress.unlock(&"bow_piercing"))
	assert(not progress.can_unlock(&"bow_finisher"))
	assert(progress.unlock(&"bow_sweep"))
	assert(progress.unlock(&"bow_quickdraw"))
	assert(progress.can_unlock(&"bow_finisher"))
	assert(progress.unlock(&"bow_finisher"))
	assert(progress.has_skill(&"bow_finisher"))
	assert(progress.skill_points == 16)

	# The daggers and staff branches have independent prerequisites.
	assert(not progress.can_unlock(&"daggers_execution"))
	assert(progress.unlock(&"daggers_flurry"))
	assert(progress.unlock(&"daggers_precision"))
	assert(not progress.can_unlock(&"daggers_execution"))
	assert(progress.unlock(&"daggers_lunge"))
	assert(progress.unlock(&"daggers_execution"))
	assert(not progress.can_unlock(&"staff_echo"))
	assert(progress.unlock(&"staff_overcharge"))
	assert(progress.unlock(&"staff_focus"))
	assert(progress.unlock(&"staff_channel"))
	assert(progress.unlock(&"staff_echo"))

	# Acquisition gates are mapped to the exact existing inventory IDs.
	assert(SkillCatalog.weapon_item(&"bow_sweep") == &"hunter_bow")
	assert(SkillCatalog.weapon_item(&"daggers_flurry") == &"shadow_daggers")
	assert(SkillCatalog.weapon_item(&"staff_focus") == &"apprentice_staff")
	assert(SkillCatalog.weapon_item(&"sword_finale") == &"rusted_sword")
	assert(SkillCatalog.weapon_item(&"survival_breath") == &"")
	assert(SkillCatalog.DATA.size() == SkillCatalog.ORDER.size())
	for skill_id in SkillCatalog.ORDER:
		assert(SkillCatalog.DATA.has(skill_id))
		assert(int(SkillCatalog.DATA[skill_id]["tier"]) >= 1)
		print("VERIFIED: ", skill_id)

	print("Weapon skill tree assertions passed")
	quit(0)
