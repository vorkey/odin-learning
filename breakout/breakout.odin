package breakout

import "core:fmt"
import "core:log"
import "core:math"
import "core:math/linalg"
import "core:math/linalg/glsl"
import "core:math/rand"
import rl "vendor:raylib"

SCREEN_SIZE :: 320
PADDLE_WIDTH :: 50
PADDLE_HEIGHT :: 6
PADDLE_POS_Y :: 260
PADDLE_SPEED :: 200
BALL_SPEED :: 260
BALL_RADIUS :: 4
BALL_START_Y :: 160
NUM_BLOCKS_X :: 10
NUM_BLOCKS_Y :: 8
BLOCK_WIDTH :: 28
BLOCK_HEIGHT :: 10
GRAY :: rl.Color{142, 129, 112, 255}

Block_Color :: enum {
	Green,
	Purple,
	Red,
	Yellow,
}

row_colors := [NUM_BLOCKS_Y]Block_Color {
	.Green,
	.Yellow,
	.Purple,
	.Red,
	.Red,
	.Purple,
	.Yellow,
	.Green,
}

// enum_array
block_color_values := [Block_Color]rl.Color {
	.Green  = {128, 128, 37, 255},
	.Purple = {150, 83, 114, 255},
	.Red    = {203, 35, 31, 255},
	.Yellow = {183, 129, 42, 255},
}

block_color_score := [Block_Color]int {
	.Green  = 2,
	.Purple = 6,
	.Red    = 8,
	.Yellow = 4,
}

paddle_pos_x: f32
ball_pos: rl.Vector2
ball_dir: rl.Vector2
blocks: [NUM_BLOCKS_X][NUM_BLOCKS_Y]bool // 2d bools array
started: bool
game_over: bool
score: int
accumulated_time: f32
previous_ball_pos: rl.Vector2
previous_paddle_pos_x: f32
clear: bool

restart :: proc() {
	started = false
	game_over = false
	clear = false
	score = 0
	paddle_pos_x = (SCREEN_SIZE - PADDLE_WIDTH) / 2
	previous_paddle_pos_x = paddle_pos_x
	ball_pos = {SCREEN_SIZE / 2, BALL_START_Y}
	previous_ball_pos = ball_pos

	for x in 0 ..< NUM_BLOCKS_X {
		for y in 0 ..< NUM_BLOCKS_Y do blocks[x][y] = true
	}
}

reflect :: proc(dir, normal: rl.Vector2) -> rl.Vector2 {
	new_dir := linalg.reflect(dir, linalg.normalize(normal))
	return linalg.normalize(new_dir)
}

calc_block_rect :: proc(x, y: int) -> rl.Rectangle {
	return {f32(20 + x * BLOCK_WIDTH), f32(40 + y * BLOCK_HEIGHT), BLOCK_WIDTH, BLOCK_HEIGHT}
}

block_exists :: proc(x, y: int) -> bool {
	if x < 0 || y < 0 || x >= NUM_BLOCKS_X || y >= NUM_BLOCKS_Y do return false
	return blocks[x][y]
}

draw_text_center :: proc(text: cstring) {
	text_width := rl.MeasureText(text, 15)
	rl.DrawText(text, (SCREEN_SIZE - text_width) / 2, BALL_START_Y - 30, 15, GRAY)
}

main :: proc() {
	rl.SetConfigFlags({.VSYNC_HINT})
	rl.InitWindow(640, 640, "Breakout!")
	rl.InitAudioDevice()
	rl.SetTargetFPS(480)


	ball_texture := rl.LoadTexture("ball.png")
	paddle_texture := rl.LoadTexture("paddle.png")

	hit_block_sound := rl.LoadSound("hit_block.wav")
	hit_paddle_sound := rl.LoadSound("hit_paddle.wav")
	game_over_sound := rl.LoadSound("game_over.wav")

	restart()

	for !rl.WindowShouldClose() {
		paddle_move_velocity: f32
		DT :: 1.0 / 60.0 // fixed timestep

		if !started {
			ball_pos = {
				SCREEN_SIZE / 2 + f32(math.cos(rl.GetTime())) * SCREEN_SIZE / 2.5,
				BALL_START_Y,
			}

			previous_ball_pos = ball_pos

			// what the heck this part below probably very important, vector and stuff
			if rl.IsKeyPressed(.SPACE) {
				paddle_middle := rl.Vector2{paddle_pos_x + PADDLE_WIDTH / 2, PADDLE_POS_Y}
				// make ball go to middle paddle (vector subtract)
				ball_to_paddle := paddle_middle - ball_pos
				// ball_dir = {0, 1} // move ball downward
				ball_dir = linalg.normalize0(ball_to_paddle) // move ball towards paddle
				started = true
			}
		} else if game_over || clear {
			if rl.IsKeyPressed(.SPACE) {
				restart()
			}
		} else {
			accumulated_time += rl.GetFrameTime()
		}


		for accumulated_time >= DT {
			previous_ball_pos = ball_pos
			previous_paddle_pos_x = paddle_pos_x
			ball_pos += ball_dir * BALL_SPEED * DT

			// bounce right wall
			if ball_pos.x + BALL_RADIUS > SCREEN_SIZE {
				ball_pos.x = SCREEN_SIZE - BALL_RADIUS
				ball_dir = reflect(ball_dir, {-1, 0})
			}

			// bounce left wall
			if ball_pos.x - BALL_RADIUS < 0 {
				ball_pos.x = BALL_RADIUS
				ball_dir = reflect(ball_dir, {1, 0})
			}

			// bounce top
			if ball_pos.y - BALL_RADIUS < 0 {
				ball_pos.y = BALL_RADIUS
				ball_dir = reflect(ball_dir, {0, 1})
			}

			// fall through bottom
			if !game_over && !clear && ball_pos.y > SCREEN_SIZE + BALL_RADIUS * 6 {
				game_over = true
				rl.PlaySound(game_over_sound)
			}

			if rl.IsKeyDown(.LEFT) {
				paddle_move_velocity -= PADDLE_SPEED
			} else if rl.IsKeyDown(.RIGHT) {
				paddle_move_velocity += PADDLE_SPEED
			}

			paddle_pos_x += paddle_move_velocity * DT
			paddle_pos_x = clamp(paddle_pos_x, 0, SCREEN_SIZE - PADDLE_WIDTH)

			paddle_rect := rl.Rectangle{paddle_pos_x, PADDLE_POS_Y, PADDLE_WIDTH, PADDLE_HEIGHT}

			// ball bouncing with paddle
			if rl.CheckCollisionCircleRec(ball_pos, BALL_RADIUS, paddle_rect) {
				collision_normal: rl.Vector2

				// push ball up
				if previous_ball_pos.y < paddle_rect.y + paddle_rect.height {
					collision_normal += {0, -1}
					ball_pos.y = paddle_rect.y - BALL_RADIUS
				}

				// push ball down
				if previous_ball_pos.y > paddle_rect.y + paddle_rect.height {
					collision_normal += {0, 1}
					ball_pos.y = paddle_rect.y + paddle_rect.height + BALL_RADIUS
				}

				// push left
				if previous_ball_pos.x < paddle_rect.x {
					collision_normal += {-1, 0}
				}

				// push right
				if previous_ball_pos.x > paddle_rect.x + paddle_rect.width {
					collision_normal += {1, 0}
				}

				if collision_normal != 0 {
					ball_dir = reflect(ball_dir, collision_normal)
				}
				rl.PlaySound(hit_paddle_sound)
			}

			found: bool
			block_x_loop: for x in 0 ..< NUM_BLOCKS_X {
				for y in 0 ..< NUM_BLOCKS_Y {
					if blocks[x][y] == false {
						continue
					} else {
						found = true
					}

					block_rect := calc_block_rect(x, y)

					if rl.CheckCollisionCircleRec(ball_pos, BALL_RADIUS, block_rect) {
						collision_normal: rl.Vector2

						if previous_ball_pos.y < block_rect.y {
							collision_normal += {0, -1}
						}

						if previous_ball_pos.y > block_rect.y + block_rect.height {
							collision_normal += {0, 1}
						}

						if previous_ball_pos.x < block_rect.x {
							collision_normal += {-1, 0}
						}

						if previous_ball_pos.x > block_rect.x + block_rect.width {
							collision_normal += {1, 0}
						}

						if block_exists(x + int(collision_normal.x), y) {
							collision_normal.x = 0
						}

						if block_exists(x, y + int(collision_normal.y)) {
							collision_normal.y = 0
						}

						if collision_normal != 0 {
							ball_dir = reflect(ball_dir, collision_normal)
						}

						blocks[x][y] = false
						row_color := row_colors[y]
						score += block_color_score[row_color]
						rl.SetSoundPitch(hit_block_sound, rand.float32_range(0.8, 1.2))
						rl.PlaySound(hit_block_sound)
						break block_x_loop
					}
				}
			}
			if !found do clear = true
			accumulated_time -= DT
		}

		blend := accumulated_time / DT
		ball_render_pos := math.lerp(previous_ball_pos, ball_pos, blend) // linear interpolation
		paddle_render_pos_x := math.lerp(previous_paddle_pos_x, paddle_pos_x, blend)


		rl.BeginDrawing()
		rl.ClearBackground({1, 7, 16, 255})

		camera := rl.Camera2D {
			zoom = f32(rl.GetScreenHeight() / SCREEN_SIZE),
		}

		rl.BeginMode2D(camera)

		rl.DrawTextureV(paddle_texture, {paddle_render_pos_x, PADDLE_POS_Y}, rl.WHITE)
		rl.DrawTextureV(ball_texture, ball_render_pos - {BALL_RADIUS, BALL_RADIUS}, rl.WHITE)


		for x in 0 ..< NUM_BLOCKS_X {
			for y in 0 ..< NUM_BLOCKS_Y {
				if blocks[x][y] == false {
					continue
				}

				block_rect := calc_block_rect(x, y)

				top_left := rl.Vector2{block_rect.x, block_rect.y}

				top_right := rl.Vector2{block_rect.x + block_rect.width, block_rect.y}

				bottom_left := rl.Vector2{block_rect.x, block_rect.y + block_rect.height}

				bottom_right := rl.Vector2 {
					block_rect.x + block_rect.width,
					block_rect.y + block_rect.height,
				}

				rl.DrawRectangleRec(block_rect, block_color_values[row_colors[y]])
				rl.DrawLineEx(top_left, top_right, 1, {255, 255, 150, 100})
				rl.DrawLineEx(top_left, bottom_left, 1, {255, 255, 150, 100})
				rl.DrawLineEx(top_right, bottom_right, 1, {0, 0, 50, 100})
				rl.DrawLineEx(bottom_left, bottom_right, 1, {0, 0, 50, 100})

			}
		}

		score_text := fmt.ctprint(score)
		rl.DrawText(score_text, 5, 5, 10, GRAY)

		if !started {
			start_text := fmt.ctprint("Start: SPACE")
			draw_text_center(start_text)
		}

		if clear {
			clear_text := fmt.ctprintf("ALL CLEAR! Reset: SPACE")
			draw_text_center(clear_text)
		}

		if game_over {
			game_over_text := fmt.ctprintf("Score: %v | Reset: SPACE", score)
			draw_text_center(game_over_text)
		}

		rl.EndMode2D()
		rl.EndDrawing()

		free_all(context.temp_allocator)
	}

	rl.CloseAudioDevice()
	rl.CloseWindow()
}
