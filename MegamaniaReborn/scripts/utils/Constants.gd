extends Node

const GAME_TITLE := "MegaMania Reborn"
const GAME_VERSION := "0.9.7 QA"

const VIEWPORT_WIDTH := 1280
const VIEWPORT_HEIGHT := 720

const PLAYER_SPEED := 400.0
const PLAYER_ACCELERATION := 2500.0
const PLAYER_FRICTION := 1800.0
const PLAYER_MAX_HEALTH := 3
const PLAYER_DASH_SPEED := 1200.0
const PLAYER_DASH_DURATION := 0.15
const PLAYER_DASH_COOLDOWN := 0.8
const PLAYER_INVULNERABILITY_TIME := 1.5
const PLAYER_SHOOT_COOLDOWN := 0.12
const PLAYER_BULLET_SPEED := 800.0

const ENEMY_KAMIKAZE_SPEED := 250.0
const ENEMY_KAMIKAZE_HEALTH := 1
const ENEMY_KAMIKAZE_SCORE := 100
const ENEMY_KAMIKAZE_SPEED_PER_WAVE := 8.0

const ENEMY_SNIPER_SPEED := 80.0
const ENEMY_SNIPER_HEALTH := 2
const ENEMY_SNIPER_SCORE := 200
const ENEMY_SNIPER_SHOOT_COOLDOWN := 1.5
const ENEMY_SNIPER_BULLET_SPEED := 350.0
const ENEMY_SNIPER_PREFERRED_DISTANCE := 300.0
const ENEMY_SNIPER_HP_PER_WAVE := 0.5
const ENEMY_SNIPER_CD_PER_WAVE := -0.05

const ENEMY_TANK_SPEED := 60.0
const ENEMY_TANK_HEALTH := 5
const ENEMY_TANK_SCORE := 500
const ENEMY_TANK_HP_PER_WAVE := 1
const ENEMY_TANK_SPEED_PER_WAVE := 3.0

const ENEMY_DIVIDER_SPEED := 150.0
const ENEMY_DIVIDER_HEALTH := 3
const ENEMY_DIVIDER_SCORE := 150
const ENEMY_DIVIDER_CHILD_SCORE := 50
const ENEMY_DIVIDER_HP_PER_WAVE := 0.5

const ENEMY_INVISIBLE_SPEED := 200.0
const ENEMY_INVISIBLE_HEALTH := 1
const ENEMY_INVISIBLE_SCORE := 200
const ENEMY_INVISIBLE_CYCLE := 3.5
const ENEMY_INVISIBLE_VISIBLE_TIME := 2.0

const ENEMY_SHIELD_SPEED := 100.0
const ENEMY_SHIELD_HEALTH := 2
const ENEMY_SHIELD_SCORE := 300
const ENEMY_SHIELD_HP := 3
const ENEMY_SHIELD_RECHARGE_TIME := 4.0
const ENEMY_SHIELD_HP_PER_WAVE := 0.5
const ENEMY_SHIELD_CD_PER_WAVE := -0.1

const ENEMY_INVOKER_SPEED := 60.0
const ENEMY_INVOKER_HEALTH := 4
const ENEMY_INVOKER_SCORE := 400
const ENEMY_INVOKER_SPAWN_INTERVAL := 3.0
const ENEMY_INVOKER_HP_PER_WAVE := 1
const ENEMY_INVOKER_SPAWN_CD_PER_WAVE := -0.1

const WAVE_PREP_TIME := 2.0
const BASE_ENEMIES_PER_WAVE := 4
const ENEMIES_PER_WAVE_INCREMENT := 2
const SPAWN_MARGIN := 80.0
const MIN_SPAWN_INTERVAL := 0.25
const SPAWN_INTERVAL_BASE := 1.0
const SPAWN_INTERVAL_DECAY := 0.035

const SCREEN_SHAKE_DURATION := 0.3
const SCREEN_SHAKE_INTENSITY := 8.0

enum PickupType { HEALTH, SHIELD, WEAPON_UP, SCORE_MULTI, SPEED_BOOST }

const PICKUP_DROP_CHANCE_BASE := 0.2
const PICKUP_DROP_CHANCE_TANK := 0.4
const PICKUP_LIFETIME := 8.0
const PICKUP_FALL_SPEED := 30.0
const PICKUP_PULSE_SPEED := 3.0

const SHIELD_DURATION := 3.0
const WEAPON_UP_DURATION := 4.0
const WEAPON_UP_COOLDOWN_MULT := 0.5
const SCORE_MULTI_DURATION := 4.0
const SCORE_MULTI_VALUE := 2
const SPEED_BOOST_DURATION := 2.5
const SPEED_BOOST_MULT := 1.4

enum WeaponType { BASIC, LASER, PLASMA, MISSILE, SHOTGUN }
const WEAPON_COUNT := 5
const WEAPON_NAMES := ["BASIC", "LASER", "PLASMA", "MISSILE", "SHOTGUN"]
const WEAPON_COOLDOWNS := [0.12, 0.06, 0.35, 0.55, 0.45]
const WEAPON_DAMAGES := [1, 1, 3, 4, 1]
const WEAPON_SPEEDS := [800.0, 1000.0, 350.0, 450.0, 700.0]
const WEAPON_SCENES := [
	"res://scenes/bullets/BulletPlayer.tscn",
	"res://scenes/bullets/BulletLaser.tscn",
	"res://scenes/bullets/BulletPlasma.tscn",
	"res://scenes/bullets/BulletMissile.tscn",
	"res://scenes/bullets/BulletShotgun.tscn",
]
const SHOTGUM_PELLETS := 5
const SHOTGUN_SPREAD := 0.3
const MISSILE_HOMING_STRENGTH := 3.0
const MISSILE_LIFETIME := 4.0

const BOSS_WAVE_INTERVAL := 5
const BOSS_BASE_HEALTH := 50
const BOSS_HEALTH_PER_WAVE := 15
const BOSS_SPEED := 120.0
const BOSS_SCORE := 5000
const BOSS_SHOOT_COOLDOWN := 1.5
const BOSS_BURST_COUNT := 3
const BOSS_SPREAD_COUNT := 8
const BOSS_PHASE_TRANSITION_DELAY := 1.0
const BOSS_DRONE_COUNT := 3

const BOSS_RUSH_HP_PER_WAVE := 15
const BOSS_RUSH_SPEED_MULT_PER_WAVE := 0.06
const BOSS_RUSH_CD_MULT_PER_WAVE := -0.04

const GROUPS := {
	PLAYER = "player",
	ENEMY = "enemy",
	PLAYER_BULLET = "player_bullet",
	ENEMY_BULLET = "enemy_bullet",
	PICKUP = "pickup",
}

const SAVE_PATH := "user://save.cfg"

const STARTING_CREDITS := 0

enum ShipType { INTERCEPTOR, BASTION, STRIKER, GHOST, CANNON }

const SHIP_NAMES := ["Interceptor", "Bastion", "Striker", "Ghost", "Cannon"]

const SHIP_DESCRIPTIONS := [
	"The original — balanced in all respects.",
	" +2 HP, -20% speed. Starts with Shield.",
	"+25% damage, -1 HP. Starts with WeaponUp.",
	"+15% speed, dash cooldown -0.5s. Starts with SpeedBoost.",
	"Starts with Missile launcher, +20% fire rate, -10% speed.",
]

const SHIP_COSTS := [0, 500, 1000, 2000, 3000]

const SHIP_MODIFIERS := [
	{ hp=0, speed=1.0, damage=1.0, fire_rate=1.0, dash_cd=0.0, start_pickup=-1 },
	{ hp=2, speed=0.8, damage=1.0, fire_rate=1.0, dash_cd=0.0, start_pickup=PickupType.SHIELD },
	{ hp=-1, speed=1.0, damage=1.25, fire_rate=1.0, dash_cd=0.0, start_pickup=PickupType.WEAPON_UP },
	{ hp=0, speed=1.15, damage=1.0, fire_rate=1.0, dash_cd=-0.5, start_pickup=PickupType.SPEED_BOOST },
	{ hp=0, speed=0.9, damage=1.0, fire_rate=1.2, dash_cd=0.0, start_pickup=-1 },
]

enum UpgradeType { MAX_HP, SPEED, FIRE_RATE, DASH_CD, SHIELD_DUR, SCORE_MULT, START_WEAPON }

const UPGRADE_NAMES := ["Max HP", "Move Speed", "Fire Rate", "Dash CD", "Shield Duration", "Score Multiplier", "Starting Weapon"]

const UPGRADE_COSTS := [
	[200, 500, 1000],
	[200, 500, 1000],
	[300, 600, 1200],
	[300, 600, 1200],
	[200, 400, 800],
	[400, 800, 1600],
	[500, 1000, 2000],
]

const UPGRADE_MAX_LEVEL := 3
const UPGRADE_COUNT := 7

const SHIP_COUNT := 5

const MEGA_CREDITS_PER_KILL := 5
const MEGA_CREDITS_PER_BOSS := 50
const MEGA_CREDITS_WAVE_BONUS := 10

enum GameMode { ARCADE, BOSS_RUSH, SURVIVAL, DAILY_CHALLENGE }

const MODE_NAMES := ["Arcade", "Boss Rush", "Survival", "Daily Challenge"]

const MODE_DESCRIPTIONS := [
	"Progressive waves with a boss every 5. Classic experience.",
	"Face bosses back-to-back. No regular enemies. 5 lives.",
	"Infinite waves, escalating difficulty. How long can you last?",
	"Same seed for everyone today. Fixed ship & upgrades.",
]

const MODE_LIVES := [3, 5, 3, 3]
const MODE_BOSS_INTERVAL := [5, 1, 0, 5]
const MODE_HAS_ENEMIES := [true, false, true, true]
const MODE_INFINITE := [false, false, true, false]
