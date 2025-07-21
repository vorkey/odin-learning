package raylib_game

import rl "vendor:raylib"

main :: proc() {
	rl.InitWindow(1280, 720, "Hello Raylib")
	player_pos := rl.Vector2{640, 320} // x, y
	player_size := rl.Vector2{64, 128}
	player_velocity: rl.Vector2
	player_grounded: bool

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground(rl.VIOLET)

		// velocity based horizontal movement
		if rl.IsKeyDown(.LEFT) {
			player_velocity.x = -400
		} else if rl.IsKeyDown(.RIGHT) {
			player_velocity.x = 400
		} else {
			player_velocity.x = 0
		}

		player_velocity.y += 2000 * rl.GetFrameTime()

		if player_grounded && rl.IsKeyPressed(.SPACE) {
			player_velocity.y = -600 // goes upward, (0,0) on top left
			player_grounded = false
		}

		// adding vector
		player_pos += player_velocity * rl.GetFrameTime() // move at 400 pixels/second, delta time included?

		// disallow player falling through screen
		if player_pos.y > f32(rl.GetScreenHeight()) - player_size.y {
			player_pos.y = f32(rl.GetScreenHeight()) - player_size.y
			player_grounded = true
		}

		// create a rectangle using vector
		rl.DrawRectangleV(player_pos, player_size, rl.WHITE)

		rl.EndDrawing()
	}

	rl.CloseWindow()
}
