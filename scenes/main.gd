extends Node

@export var snake_scene : PackedScene

#game variables
var score : int
var game_started : bool = false

#grid variables
var cells_number : int = 20
var cell_size : int = 50
#snake variables
var old_position : Array
var snake_position : Array
var snake_size : Array

#food variables
var food_position : Vector2
var regenerate_food : bool = true


#movement variables
var start_position = Vector2(9, 9)
var up = Vector2(0, -1)
var down = Vector2(0, 1)
var left = Vector2(-1, 0)
var right = Vector2(1, 0)
var move_direction : Vector2
var can_move : bool

func _ready():
	new_game()

func new_game():
	get_tree().paused = false
	get_tree().call_group("snakeSegments", "queue_free")
	$GameOverMenu.hide()
	score = 0
	$Hud.get_node("ScoreLabel").text = "SCORE: " + str(score)
	move_direction = up
	can_move = true
	generate_snake()
	move_food()
	
func generate_snake():
	old_position.clear()
	snake_position.clear()
	snake_size.clear()
	#starting with the initial position, create tail segments vertically down
	for i in range (3):
		add_segment(start_position + Vector2(0, i))
	
func add_segment(position):
	snake_position.append(position)
	var snakeSegment = snake_scene.instantiate()
	snakeSegment.position = (position * cell_size) + Vector2(0, cell_size)
	add_child(snakeSegment)
	snake_size.append(snakeSegment)

func _process(delta):
	move_snake()

func move_snake():
	if can_move:
		if Input.is_action_just_pressed("move_down") and move_direction != up:
			move_direction = down
			can_move = false
			if not game_started:
				start_game()
		#up movement check
		if Input.is_action_just_pressed("move_up") and move_direction != down:
			move_direction = up
			can_move = false
			if not game_started:
				start_game()
		#left movement check
		if Input.is_action_just_pressed("move_left") and move_direction != right:
			move_direction = left
			can_move = false
			if not game_started:
				start_game()
		#right movement check
		if Input.is_action_just_pressed("move_right") and move_direction != left:
			move_direction = right
			can_move = false
			if not game_started:
				start_game()

func start_game():
	game_started = true
	$MoveTimer.start()


func _on_move_timer_timeout():
	can_move = true
	#using snakes old position to move new segments
	old_position = [] + snake_position
	#moves snake's head to new position
	snake_position[0] += move_direction
	#moves all segments along by one
	for i in range(len(snake_position)):
		if i > 0 :
			snake_position[i] = old_position[i - 1]
		snake_size[i].position = (snake_position[i] * cell_size) + Vector2(0, cell_size)
	check_out_of_bounds()
	check_self_eaten()
	check_food_eaten()
	

func check_out_of_bounds():
	if snake_position[0].x < 0 or snake_position[0].x > cells_number - 1 or snake_position[0].y < 0 or snake_position[0].y > cells_number - 1:
		end_game()

func check_self_eaten():
	for i in range(1, len(snake_position)):
		if snake_position[0] == snake_position[i]:
			end_game()

func move_food():
	while regenerate_food:
		regenerate_food = false
		food_position = Vector2(randi_range(0, cells_number - 1), randi_range(0, cells_number - 1))
		for i in snake_position:
			if food_position == i:
				regenerate_food = true
	$Food.position = (food_position * cell_size) + Vector2(0, cell_size)
	regenerate_food = true
	
#if snake eats food, add new segment and move food
func check_food_eaten():
	if snake_position[0] == food_position:
		score += 1
		$Hud.get_node("ScoreLabel").text = "SCORE: " + str(score)
		add_segment(old_position[-1])
		move_food()


func end_game():
	$GameOverMenu.show()
	$MoveTimer.stop()
	game_started = false
	get_tree().paused = true
	


func _on_game_over_menu_restart():
	new_game()
