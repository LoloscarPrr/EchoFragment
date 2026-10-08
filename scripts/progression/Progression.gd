class_name Progression
extends Resource

signal experience_changed(current: int, required: int)
signal level_changed(level: int, skill_points: int)
signal skill_points_changed(points: int)
signal skill_unlocked(skill_id: StringName)

@export var level := 1
@export var experience := 0
@export var skill_points := 0
@export var unlocked_skills: Array[StringName] = []

func xp_required_for_level(target_level: int) -> int:
	return 100 + ((target_level - 1) * 60)

func add_experience(amount: int) -> void:
	if amount <= 0:
		return
	experience += amount
	var required := xp_required_for_level(level)
	while experience >= required:
		experience -= required
		level += 1
		skill_points += 1
		level_changed.emit(level, skill_points)
		required = xp_required_for_level(level)
	experience_changed.emit(experience, required)
	skill_points_changed.emit(skill_points)

func can_unlock(skill_id: StringName) -> bool:
	return skill_points > 0 and not unlocked_skills.has(skill_id)

func unlock(skill_id: StringName) -> bool:
	if not can_unlock(skill_id):
		return false
	unlocked_skills.append(skill_id)
	skill_points -= 1
	skill_unlocked.emit(skill_id)
	skill_points_changed.emit(skill_points)
	return true

func has_skill(skill_id: StringName) -> bool:
	return unlocked_skills.has(skill_id)
