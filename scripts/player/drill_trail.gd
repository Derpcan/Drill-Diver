extends Node2D

@export var enabled : bool = true
@export var max_points : int = 40
@export var alpha : float = 0.4
@export var fade_out_time : float = 0.2

@onready var player : Player = get_tree().get_first_node_in_group("player")
@onready var cg : CanvasGroup = $CanvasGroup
@onready var trail : Line2D = $"CanvasGroup/Line2D"
@onready var particles : GPUParticles2D = $GPUParticles2D
var is_drilling : bool = false

var desired_offset_local := Vector2(12.0, -2.25)
var current_offset_global := Vector2.ZERO
var offset_speed := 10.0

func _ready() -> void:
	var drill_detector = null
	
	if player:
		for child in player.get_children():
			if child.name == "DrillDetector":
				drill_detector = child
	
	if drill_detector:
		drill_detector.body_entered.connect(_started_drilling)
		drill_detector.body_exited.connect(_stopped_drilling)
	
	cg.self_modulate.a = alpha
	particles.emitting = false

func _physics_process(delta: float) -> void:
	global_position = Vector2.ZERO
	global_rotation = 0
	
	if is_drilling && enabled:
		# Add trail point with smooth offset
		var target_global = player.global_position + desired_offset_local.rotated(player.global_rotation)
		current_offset_global = current_offset_global.lerp(target_global, delta * offset_speed)
		trail.add_point(current_offset_global)
		
		
		if trail.points.size() > max_points:
			trail.remove_point(0)
		
		# Particles
		particles.position = current_offset_global

func _started_drilling(_arg) -> void:
	is_drilling = true
	# Initialize smoothed offset at first point
	current_offset_global = player.global_position + desired_offset_local.rotated(player.global_rotation)
	
	if enabled:
		# Clear old points
		trail.remove_point(0)
		trail.queue_redraw()
		
		particles.emitting = true

func _stopped_drilling(_arg) -> void:
	is_drilling = false
	fade_out()

func fade_out() -> void:
	if enabled:
		var tween = create_tween()
		tween.tween_property(cg, "self_modulate:a", 0.0, fade_out_time)
		tween.finished.connect(func ():
			trail.points = []
			cg.self_modulate.a = alpha
			trail.queue_redraw()
			)
		
		particles.emitting = false
