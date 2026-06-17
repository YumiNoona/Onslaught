extends Node

@export_category("Slow Motion")
## Time scale during player death slow-motion. Lower = slower (0.0 = frozen, 1.0 = normal)
@export var player_death_time_scale: float = 0.2
## How long (in real-time seconds) player death slow-motion lasts
@export var player_death_duration: float = 1.0
## Time scale during boss death slow-motion. Lower = slower
@export var boss_death_time_scale: float = 0.2
## How long (in real-time seconds) boss death slow-motion lasts
@export var boss_death_duration: float = 1.0

@export_category("Camera Shake")
## Base shake trauma applied per shake request, before multiplier
@export var shake_base_strength: float = 0.05
## How fast camera shake trauma decays per second. Higher = shorter shake
@export var shake_decay_rate: float = 0.15
## Maximum camera rotation (radians) during shake. Higher = more chaotic
@export var shake_max_roll: float = 0.15
## Pixel offset multiplier for camera shake displacement
@export var shake_offset_multiplier: float = 15.0
## Shake intensity when a boss enemy spawns
@export var shake_boss_spawn: float = 5.0
## Shake intensity when a normal enemy spawns
@export var shake_normal_spawn: float = 0.3
## Shake intensity when a boss dies
@export var shake_boss_death: float = 1.5
## Shake intensity when a normal enemy dies
@export var shake_enemy_death: float = 0.5
## Shake intensity when player takes damage
@export var shake_player_hit: float = 2.0
## Shake intensity for Ground Slam ability
@export var shake_ground_slam: float = 3.0
## Shake intensity when player levels up
@export var shake_level_up: float = 3.0
## Shake intensity when picking up a power-up
@export var shake_powerup_pickup: float = 1.0

@export_category("Player Stats")
## Base movement speed of the player
@export var player_move_speed: float = 700.0
## Maximum health of the player
@export var player_max_health: float = 10.0
## Health restored on each level-up
@export var health_on_level_up: float = 1.0

@export_category("Player Dash")
## Speed during dash roll
@export var dash_speed: float = 1500.0
## Duration of dash roll in seconds
@export var dash_duration: float = 0.3
## Cooldown between dashes in seconds
@export var dash_cooldown: float = 1.0
## Maximum trail points for dash visual effect
@export var dash_trail_max_points: int = 15
## How fast the dash trail fades out in seconds
@export var dash_trail_fade_duration: float = 0.15

@export_category("Character Abilities — Adrenaline Rush (Shooter)")
## Adrenaline Rush cooldown in seconds
@export var adrenaline_cooldown: float = 10.0
## Adrenaline Rush effect duration in seconds
@export var adrenaline_duration: float = 3.0
## Movement speed multiplier during Adrenaline Rush (1.2 = +20%)
@export var adrenaline_speed_mult: float = 1.2
## Fire rate boost during Adrenaline Rush (added to fire_rate_mod)
@export var adrenaline_fire_rate_boost: float = 0.2

@export_category("Character Abilities — Ground Slam (Rocky)")
## Ground Slam cooldown in seconds
@export var ground_slam_cooldown: float = 6.0
## Ground Slam damage radius in units
@export var ground_slam_range: float = 300.0
## Ground Slam damage amount
@export var ground_slam_damage: float = 3.0
## Knockback velocity applied to enemies hit by Ground Slam
@export var ground_slam_knockback: float = 800.0
## Shake intensity for Ground Slam
@export var ground_slam_shake: float = 3.0
## Initial visual scale of the Ground Slam ring
@export var ground_slam_ring_initial_scale: float = 0.1
## Maximum visual scale of the Ground Slam ring
@export var ground_slam_ring_final_scale: float = 6.0
## Duration of Ground Slam ring expansion animation in seconds
@export var ground_slam_ring_anim_duration: float = 0.3

@export_category("Character Abilities — Quick Dash (Simon)")
## Quick Dash cooldown in seconds
@export var quick_dash_cooldown: float = 2.0
## Quick Dash speed multiplier (applied on top of dash_speed)
@export var quick_dash_speed_mult: float = 1.5
## Quick Dash duration in seconds
@export var quick_dash_duration: float = 0.15
## Maximum trail points for Quick Dash visual effect
@export var quick_dash_trail_max_points: int = 10
## How fast the Quick Dash trail fades out in seconds
@export var quick_dash_trail_fade_duration: float = 0.1

@export_category("Enemy Stats")
## Base movement speed of normal enemies
@export var enemy_move_speed: float = 400.0
## Damage dealt to player on enemy contact
@export var enemy_contact_damage: float = 1.0
## Minimum interval between contact damage ticks in seconds
@export var enemy_damage_cooldown: float = 1.5
## Distance at which enemies stop moving toward the player
@export var enemy_stop_distance: float = 120.0
## Duration of hit/armor flash effect on enemies in seconds
@export var hit_flash_duration: float = 0.3

@export_category("Healer Enemy")
## Radius within which healer enemies heal allies
@export var healer_heal_range: float = 200.0
## Health restored per heal pulse
@export var healer_heal_amount: float = 3.0
## Interval between heal pulses in seconds
@export var healer_heal_cooldown: float = 4.0

@export_category("Enemy Spawner")
## Base number of enemies per normal wave (before scaling)
@export var base_enemies_per_wave: int = 5
## Extra HP added to enemies per wave completed
@export var hp_per_wave: float = 2.0
## Maximum wave number for early-tier enemies only
@export var early_wave_max: int = 3
## Maximum wave number for mid-tier enemies (after this, hard enemies appear)
@export var mid_wave_max: int = 7
## Minimum possible spawn timer in seconds (won't go below this)
@export var spawn_timer_min_floor: float = 0.2
## Maximum possible spawn timer in seconds (won't go below this)
@export var spawn_timer_max_floor: float = 0.5
## Minimum distance from player for enemy spawns
@export var spawn_distance_min: float = 500.0
## Maximum distance from player for enemy spawns
@export var spawn_distance_max: float = 800.0
## World boundary clamping value (+/- this amount on X and Y axes)
@export var world_bound: float = 3000.0

@export_category("Boss")
## Initial boss attack interval in seconds
@export var boss_attack_cooldown_base: float = 2.0
## Boss attack interval reduction per wave (subtracted from base)
@export var boss_attack_cooldown_per_wave: float = 0.1
## Minimum boss attack interval in seconds
@export var boss_attack_cooldown_min: float = 0.5
## HP percentage threshold at which boss enrages (0.5 = 50% HP)
@export var boss_enrage_threshold: float = 0.5
## Movement speed multiplier when boss enrages
@export var boss_enrage_speed_mult: float = 1.3
## Attack interval when boss is enraged in seconds
@export var boss_enraged_attack_cooldown: float = 1.0
## Minimum coins dropped by boss on death
@export var boss_coin_drop_min: int = 5
## Random coin drop range added to minimum (min + rand % max)
@export var boss_coin_drop_max: int = 6
## Minimum distance from player for boss spawn
@export var boss_spawn_distance_min: float = 600.0
## Maximum distance from player for boss spawn
@export var boss_spawn_distance_max: float = 900.0
## Extra movement speed added to boss per wave
@export var boss_speed_per_wave: float = 5.0

@export_category("Kill Rewards")
## Base score awarded per enemy kill (multiplied by wave number)
@export var score_per_kill_base: float = 100.0
## Base XP awarded per enemy kill (multiplied by wave number)
@export var xp_per_kill_base: float = 10.0
## Chance for enemy to drop a power-up on death (0.0 to 1.0)
@export var powerup_drop_chance: float = 0.15
## Chance for enemy to drop a coin on death (0.0 to 1.0)
@export var coin_drop_chance: float = 0.5

@export_category("Enemy Death Particles")
## Number of particles spawned on enemy death
@export var death_particles_amount: int = 12
## Lifetime of each death particle in seconds
@export var death_particles_lifetime: float = 0.4
## Minimum initial velocity of death particles
@export var death_particles_velocity_min: float = 400.0
## Maximum initial velocity of death particles
@export var death_particles_velocity_max: float = 700.0
## Minimum scale of death particles
@export var death_particles_scale_min: float = 8.0
## Maximum scale of death particles
@export var death_particles_scale_max: float = 16.0
## Gravity force applied to death particles on Y axis
@export var death_particles_gravity_y: float = 200.0

@export_category("Bullet")
## Speed of bullets
@export var bullet_speed: float = 1000.0
## Maximum number of trail points on a bullet trail
@export var bullet_trail_length: int = 8
## Delay before removing bullet after impact in seconds
@export var bullet_hit_explosion_delay: float = 0.08
## Initial scale of the hit spark effect
@export var hit_spark_initial_scale: float = 0.15
## Target scale the hit spark grows to
@export var hit_spark_grow_target: float = 0.4
## Duration of hit spark fade-out in seconds
@export var hit_spark_fade_duration: float = 0.1
## Duration of hit spark growth animation in seconds
@export var hit_spark_grow_duration: float = 0.1

@export_category("PowerUps")
## Time in seconds before a power-up disappears if not picked up
@export var powerup_lifetime: float = 8.0
## Duration of SPEED power-up effect in seconds
@export var powerup_speed_duration: float = 5.0
## Duration of DAMAGE power-up effect in seconds
@export var powerup_damage_duration: float = 5.0
## Duration of INVULNERABILITY power-up effect in seconds
@export var powerup_invuln_duration: float = 3.0
## Movement speed multiplier when SPEED power-up is active (1.3 = +30%)
@export var powerup_speed_mult: float = 1.3
## Flat damage bonus when DAMAGE power-up is active
@export var powerup_damage_bonus: float = 3.0
## Minimum alpha for power-up sprite blink animation
@export var powerup_blink_alpha_min: float = 0.3
## Maximum alpha for power-up sprite blink animation
@export var powerup_blink_alpha_max: float = 1.0
## Duration of one blink cycle (fade down + fade up) in seconds
@export var powerup_blink_duration: float = 0.4
## Shake intensity when picking up a power-up
@export var powerup_pickup_shake: float = 1.0

@export_category("Economy")
## Starting coins when a new game begins
@export var starting_coins: int = 200
## Coin value (how many coins are added per coin pickup)
@export var coin_value: int = 1
## Radius at which coins are attracted toward the player
@export var magnet_radius: float = 300.0
## Speed at which coins fly toward the player when magnetized
@export var magnet_speed: float = 600.0
## Minimum X velocity when coin spawns (bounce scatter)
@export var coin_bounce_velocity_x_min: float = -300.0
## Maximum X velocity when coin spawns (bounce scatter)
@export var coin_bounce_velocity_x_max: float = 300.0
## Minimum Y velocity when coin spawns (bounce upward)
@export var coin_bounce_velocity_y_min: float = -400.0
## Maximum Y velocity when coin spawns (bounce upward)
@export var coin_bounce_velocity_y_max: float = -100.0
## Friction multiplier applied to coin bounce velocity each frame (lower = faster stop)
@export var coin_friction: float = 0.92

@export_category("XP & Leveling")
## XP required to reach level 2
@export var base_xp_to_next: int = 100
## XP curve multiplier: xp_to_next = level * this_value
@export var xp_curve_multiplier: int = 80
## Number of perk choices presented on level-up
@export var perk_choice_count: int = 3

@export_category("Difficulty")
## Enemy count multiplier for Easy difficulty (0.5 = half enemies)
@export var difficulty_easy_mult: float = 0.5
## Enemy count multiplier for Normal difficulty (1.0 = standard)
@export var difficulty_normal_mult: float = 1.0
## Enemy count multiplier for Hard difficulty (1.5 = 50% more enemies)
@export var difficulty_hard_mult: float = 1.5

@export_category("Vignette / Screen Effects")
## HP threshold below which the low-health vignette pulse activates
@export var low_health_threshold: float = 3.0
## Speed of the vignette pulse oscillation
@export var vignette_pulse_speed: float = 3.0
## Base alpha (opacity) of the low-health vignette pulse
@export var vignette_pulse_alpha_base: float = 0.3
## Range of the vignette pulse oscillation (added/subtracted from base)
@export var vignette_pulse_alpha_range: float = 0.15
## Tint color of the vignette during level-up flash
@export var level_up_tint: Color = Color(1, 0.9, 0, 1)
## Maximum alpha of the vignette during level-up flash
@export var level_up_vignette_alpha: float = 0.6
## Duration of level-up vignette fade-out in seconds
@export var level_up_vignette_fade_duration: float = 0.5
## Shake intensity when player levels up
@export var level_up_shake: float = 3.0

@export_category("Hit Flash")
## Color and opacity of the full-screen hit flash overlay
@export var hit_flash_color: Color = Color(1, 0, 0, 0.35)
## Duration of hit flash fade-out in seconds
@export var hit_flash_fade_duration: float = 0.3

@export_category("Screen Fade")
## Duration of screen fade-in on game start in seconds
@export var fade_in_duration: float = 0.5
## Delay before screen fade-in begins in seconds
@export var fade_in_delay: float = 0.3

@export_category("Crosshair")
## Speed at which crosshair recoil recovers to center
@export var crosshair_recoil_recovery: float = 3000.0
## Magnitude of crosshair recoil impulse when shooting
@export var crosshair_recoil_impulse: float = 60.0

@export_category("Wave Announcement")
## Initial scale of the wave announcement text (for pop-in effect)
@export var wave_announce_initial_scale: float = 2.0
## Duration of wave announcement scale-in animation in seconds
@export var wave_announce_scale_in_duration: float = 0.4
## Duration of wave announcement fade-out in seconds
@export var wave_announce_fade_duration: float = 0.7
## Delay before wave announcement starts fading in seconds
@export var wave_announce_fade_delay: float = 0.6

@export_category("Combo Display")
## Minimum kill streak to show combo display
@export var combo_min_streak: int = 2
## Initial scale of combo label for pop-in effect
@export var combo_pop_scale: float = 1.5
## Duration of combo label normalizing animation in seconds
@export var combo_normalize_duration: float = 0.2
## Time window for combo chain in seconds (resets if no kills in this time)
@export var combo_timer_timeout: float = 2.0

@export_category("Weapon / Reload")
## Duration of muzzle flash material effect in seconds
@export var muzzle_flash_duration: float = 0.05

@export_category("Footstep Audio")
## Minimum velocity threshold for footstep sounds
@export var footstep_velocity_threshold: float = 10.0
## Interval between footstep sounds in seconds
@export var footstep_interval: float = 0.3
## Audio mix rate for procedurally generated footstep sound
@export var footstep_mix_rate: float = 22050.0
## Maximum audible distance for footstep sounds
@export var footstep_max_distance: float = 400.0
## Base volume for footstep sounds in dB
@export var footstep_base_volume: float = -12.0
## Random volume variation for footstep sounds (+/- this value in dB)
@export var footstep_volume_variation: float = 3.0
## Envelope strength for footstep noise amplitude
@export var footstep_envelope_strength: float = 0.15

@export_category("Health Pickup")
## Health restored by a health pickup
@export var health_pickup_heal_amount: float = 10.0
## Time before health pickup disappears in seconds
@export var health_pickup_lifetime: float = 10.0
## Speed at which health pickup moves toward player
@export var health_pickup_move_speed: float = 150.0
## Distance at which health pickup starts moving toward player
@export var health_pickup_attract_distance: float = 200.0
## Collision shape radius for health pickup
@export var health_pickup_collision_radius: float = 15.0
## Duration of health pickup fade-out animation in seconds
@export var health_pickup_fade_duration: float = 0.5

@export_category("Wave Intermission")
## Wait time between waves shown on the wave label in seconds
@export var wave_timer_wait_time: float = 3.0
## Short delay after last enemy dies before next wave starts in seconds
@export var wave_completion_delay: float = 1.0
## Number of normal waves between boss waves
@export var boss_wave_interval: int = 5

@export_category("Enemy Spawn Tier Thresholds")
## Maximum wave number where only early-tier enemies spawn
@export var tier_early_only_max: int = 3
## Maximum wave number where early+mid-tier enemies spawn (after this, all tiers)
@export var tier_mid_only_max: int = 7
