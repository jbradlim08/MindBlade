extends Node

#region Player
signal on_blade_platform(pos: Vector2, has_blade: bool)
signal on_throw_blade(pos: Vector2, has_blade: bool)
signal on_jump_on_air(pos: Vector2)
signal on_player_hit()
signal on_player_hurt()
signal on_player_die()
signal on_player_crit()
signal on_player_put_checkpoint(pos: Vector2)
#endregion

#region HeadKnife
signal on_hk_die(pos: Vector2, dir: float)
#endregion
