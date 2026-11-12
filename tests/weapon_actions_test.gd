extends SceneTree

func _initialize() -> void:
	# Holding the bow should continuously scale damage and charge to a cap.
	assert(is_equal_approx(WeaponActionRules.bow_charge(0.0), 0.0))
	assert(WeaponActionRules.bow_charge(1.3) >= 1.0)
	assert(WeaponActionRules.bow_charge(30.0) == 1.0)
	assert(WeaponActionRules.bow_charge(1.0, true) == 1.0)
	assert(WeaponActionRules.bow_damage(20, 0.0) == 20)
	assert(WeaponActionRules.bow_damage(20, 1.0) == 46)
	assert(WeaponActionRules.bow_piercing(0.0, false) == 1)
	assert(WeaponActionRules.bow_piercing(1.0, false) == 3)
	assert(WeaponActionRules.bow_piercing(1.0, true) == 4)

	# Two thrown daggers have independent cooldowns, never a shared charge.
	var slots: Array[float] = [0.0, 0.0]
	assert(WeaponActionRules.ready_dagger_slot(slots, 0.0) == 0)
	slots[0] = 3.6
	assert(WeaponActionRules.ready_dagger_slot(slots, 0.1) == 1)
	slots[1] = 4.0
	assert(WeaponActionRules.ready_dagger_slot(slots, 2.0) == -1)
	assert(WeaponActionRules.daggers_available(slots, 2.0) == 0)
	assert(WeaponActionRules.daggers_available(slots, 3.7) == 1)
	assert(WeaponActionRules.daggers_available(slots, 4.2) == 2)
	assert(WeaponActionRules.cooldown_remaining(4.0, 5.0) == 0.0)

	print("Weapon action rules assertions passed")
	quit(0)
