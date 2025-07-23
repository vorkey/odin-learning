package breakout

import "core:math"
import "core:math/linalg"
import "core:math/linalg/glsl"
import rl "vendor:raylib"

SCREEN_SIZE :: 320
PADDLE_WIDTH :: 50
PADDLE_HEIGHT :: 6
PADDLE_POS_Y :: 260
PADDLE_SPEED :: 200
BALL_SPEED :: 260
BALL_RADIUS :: 4
BALL_START_Y :: 160

paddle_pos_x: f32
ball_pos: rl.Vector2
ball_dir: rl.Vector2
started: bool

restart :: proc() {
	started = false
	paddle_pos_x = (SCREEN_SIZE - PADDLE_WIDTH) / 2
	ball_pos = {SCREEN_SIZE / 2, BALL_START_Y}
}

reflect :: proc(dir, normal: rl.Vector2) -> rl.Vector2 {
	new_dir := linalg.reflect(dir, linalg.normalize(normal))
	return linalg.normalize(new_dir)
}

main :: proc() {
	rl.SetConfigFlags({.VSYNC_HINT})
	rl.InitWindow(640, 640, "Breakout!")
	rl.SetTargetFPS(480)

	restart()

	for !rl.WindowShouldClose() {
		paddle_move_velocity: f32
		dt: f32

		if !started {
			ball_pos = {
				SCREEN_SIZE / 2 + f32(math.cos(rl.GetTime())) * SCREEN_SIZE / 2.5,
				BALL_START_Y,
			}
			// what the heck this part below probably very important, vector and stuff
			if rl.IsKeyPressed(.SPACE) {
				paddle_middle := rl.Vector2{paddle_pos_x + PADDLE_WIDTH / 2, PADDLE_POS_Y}
				// make ball go to middle paddle (vector subtract)
				ball_to_paddle := paddle_middle - ball_pos
				// ball_dir = {0, 1} // move ball downward
				ball_dir = linalg.normalize0(ball_to_paddle) // move ball towards paddle
				started = true
			}
		} else {
			dt = rl.GetFrameTime()
		}

		previous_ball_pos := ball_pos
		ball_pos += ball_dir * BALL_SPEED * dt

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
		if ball_pos.y > SCREEN_SIZE + BALL_RADIUS * 6 {
			restart()
		}

		if rl.IsKeyDown(.LEFT) {
			paddle_move_velocity -= PADDLE_SPEED
		} else if rl.IsKeyDown(.RIGHT) {
			paddle_move_velocity += PADDLE_SPEED
		}

		paddle_pos_x += paddle_move_velocity * dt
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
		}

		rl.BeginDrawing()
		rl.ClearBackground({150, 190, 220, 255})

		camera := rl.Camera2D {
			zoom = f32(rl.GetScreenHeight() / SCREEN_SIZE),
		}

		rl.BeginMode2D(camera)

		rl.DrawRectangleRec(paddle_rect, {50, 150, 90, 255})
		rl.DrawCircleV(ball_pos, BALL_RADIUS, {200, 90, 20, 255})

		rl.EndMode2D()
		rl.EndDrawing()
	}

	rl.CloseWindow()
}
