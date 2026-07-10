extends Node

signal player_health_changed(health, max_health)
signal player_damaged(amount, position)
signal player_died(position)
signal player_respawned
signal enemy_killed(enemy_type, position, score_value)
signal enemy_spawned(enemy)
signal score_changed(new_score, delta)
signal combo_updated(combo_count)
signal wave_started(wave_number)
signal wave_cleared(wave_number)
signal game_state_changed(new_state, previous_state)
signal screen_shake(intensity, duration)
signal bullet_fired(bullet, position, direction)
signal player_dashed
signal pickup_collected(pickup_type, position)
signal pickup_expired(pickup_type)
signal power_up_activated(pickup_type, duration)
signal power_up_deactivated(pickup_type)
signal weapon_changed(weapon_index, weapon_name)
signal boss_spawned(boss_node)
signal boss_hp_changed(current_hp, max_hp)
signal boss_died(position)
