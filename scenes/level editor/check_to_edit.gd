extends CanvasLayer
class_name CheckToEdit


signal user_decided(decision_to_edit:bool)

@export var continue_button:Button
@export var cancel_button:Button
@export var animation_player:AnimationPlayer
@export var time_label:Label

func _ready() -> void:
	continue_button.pressed.connect(_continue)
	cancel_button.pressed.connect(_cancel)
	animation_player.play("loop")

func _continue() -> void:
	user_decided.emit(true)
	await get_tree().create_timer(0.15).timeout
	hide()

func _cancel() -> void:
	user_decided.emit(false)
	await get_tree().create_timer(0.15).timeout
	hide()

func prompt_for_decision(time:float) -> void:
	time_label.text = GameManager.convert_to_readable_time(time)
	show()
	#await get_tree().create_timer(1.5).timeout
	#user_decided.emit(true)
	#hide()
