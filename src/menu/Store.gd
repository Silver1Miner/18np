extends Control

signal purchase_made(swap)
onready var owned_shields = $ScrollContainer/StoreOptions/Tools/ToolOptions/OwnedShields
onready var button_shield = $ScrollContainer/StoreOptions/Tools/ToolOptions/BuyShield
onready var owned_solvers = $ScrollContainer/StoreOptions/Tools/ToolOptions/OwnedSolvers
onready var button_solver = $ScrollContainer/StoreOptions/Tools/ToolOptions/BuySolver
onready var owned_pics = $ScrollContainer/StoreOptions/Unlocks/UnlockOptions/OwnedPictures
onready var button_picture = $ScrollContainer/StoreOptions/Unlocks/UnlockOptions/BuyPicture
onready var owned_music = $ScrollContainer/StoreOptions/Unlocks/UnlockOptions/OwnedMusic
onready var button_music = $ScrollContainer/StoreOptions/Unlocks/UnlockOptions/BuyMusic
onready var support = $ScrollContainer/StoreOptions/Support
onready var confirm = $Confirm
onready var anim = $AnimationPlayer
onready var purchse_label = $Confirm/ConfirmOptions/PurchaseLabel
var cost = 0
var buy_state = 0
enum BUY {NONE, SHIELD, SOLVER, PICTURE, MUSIC}

func _ready() -> void:
	update_buttons()
	if not OS.get_name() in ["Android", "iOS"]:
		support.visible = false

func _on_BuyShield_pressed() -> void:
	if anim.is_playing():
		return
	Audio.play_sound("res://assets/audio/sounds/confirmation_001.ogg")
	cost = UserData.shield_price
	buy_state = BUY.SHIELD
	anim.play("ConfirmUp")

func _on_BuySolver_pressed() -> void:
	if anim.is_playing():
		return
	Audio.play_sound("res://assets/audio/sounds/confirmation_001.ogg")
	cost = UserData.solve_price
	buy_state = BUY.SOLVER
	anim.play("ConfirmUp")

func _on_BuyPicture_pressed() -> void:
	if anim.is_playing():
		return
	Audio.play_sound("res://assets/audio/sounds/confirmation_001.ogg")
	cost = UserData.picture_price
	buy_state = BUY.PICTURE
	anim.play("ConfirmUp")

func _on_BuyMusic_pressed() -> void:
	if anim.is_playing():
		return
	Audio.play_sound("res://assets/audio/sounds/confirmation_001.ogg")
	cost = UserData.track_price
	buy_state = BUY.MUSIC
	anim.play("ConfirmUp")

func _on_BuyTip_pressed() -> void:
	if anim.is_playing():
		return
	if Billing.android_iap:
		Billing.android_purchase(0)
		print("buy 60 gems via android")
	elif Billing.ios_iap:
		print("buy 60 gems via ios")
		Billing.ios_purchase(0)
	else:
		print("no shop connected")

func _on_BuyGems1_pressed() -> void:
	if anim.is_playing():
		return
	if Billing.android_iap:
		Billing.android_purchase(1)
		print("buy 315 gems via android")
	elif Billing.ios_iap:
		print("buy 315 gems via ios")
		Billing.ios_purchase(1)
	else:
		print("no shop connected")

func _on_BuyGems2_pressed() -> void:
	if anim.is_playing():
		return
	if Billing.android_iap:
		Billing.android_purchase(2)
		print("buy 630 gems via android")
	elif Billing.ios_iap:
		print("buy 630 gems via ios")
		Billing.ios_purchase(2)
	else:
		print("no shop connected")

func _on_BuyGems3_pressed() -> void:
	if anim.is_playing():
		return
	if Billing.android_iap:
		Billing.android_purchase(3)
		print("buy 1650 gems via android")
	elif Billing.ios_iap:
		print("buy 1650 gems via ios")
		Billing.ios_purchase(3)
	else:
		print("no shop connected")

func _on_Purchase_pressed() -> void:
	if anim.is_playing():
		return
	Audio.play_sound("res://assets/audio/sounds/confirmation_001.ogg")
	UserData.gems = int(clamp(UserData.gems - cost, 0, UserData.gems))
	var swap = false
	match buy_state:
		BUY.SHIELD:
			UserData.streak_shields = int(clamp(UserData.streak_shields+1, 0, 5))
		BUY.SOLVER:
			UserData.solvers = int(clamp(UserData.solvers+1, 0, 99))
		BUY.PICTURE:
			UserData.add_picture()
			swap = true
		BUY.MUSIC:
			UserData.add_music()
			swap = true
	emit_signal("purchase_made", swap)
	close_confirm()
	update_buttons()

func _on_Cancel_pressed() -> void:
	if anim.is_playing():
		return
	Audio.play_sound("res://assets/audio/sounds/back_002.ogg")
	close_confirm()

func close_confirm() -> void:
	if anim.is_playing():
		return
	anim.play_backwards("ConfirmUp")
	cost = 0
	buy_state = BUY.NONE
	update_buttons()

func update_buttons() -> void:
	button_shield.disabled = UserData.gems < UserData.shield_price or UserData.streak_shields >= 5
	button_solver.disabled = UserData.gems < UserData.solve_price or UserData.solvers >= 99
	button_picture.disabled = UserData.gems < UserData.picture_price or UserData.owned_pictures >= UserData.max_pictures
	button_music.disabled = UserData.gems < UserData.track_price or UserData.owned_tracks >= UserData.max_tracks
	button_picture.text = str(UserData.picture_price)
	button_music.text = str(UserData.track_price)
	owned_shields.text = "(%s/%s Owned)" % [str(UserData.streak_shields), str(UserData.max_shields)]
	owned_solvers.text = "(%s/%s Owned)" % [str(UserData.solvers), str(UserData.max_solvers)]
	owned_pics.text = "(%s/%s Unlocked)" % [str(UserData.owned_pictures), str(UserData.max_pictures)]
	owned_music.text = "(%s/%s Unlocked)" % [str(UserData.owned_tracks), str(UserData.max_tracks)]
