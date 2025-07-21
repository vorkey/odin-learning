package raylib_game

import rl "vendor:raylib"

main :: proc() {
	rl.InitWindow(1280, 720, "Hello Raylib")
	player_pos := rl.Vector2{640, 320} // x, y
	player_size := rl.Vector2{64, 64}
	player_velocity: rl.Vector2
	player_grounded: bool
	player_flip: bool
	player_run_texture := rl.LoadTexture("plae.png")
	player_run_num_frames := 4
	player_run_frame_timer: f32
	player_run_current_frame: int
	player_run_frame_length: f32 = 0.1 // since we don't want this to happen each fps

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground(rl.VIOLET)

		// velocity based horizontal movement
		if rl.IsKeyDown(.LEFT) {
			player_velocity.x = -400
			player_flip = true
		} else if rl.IsKeyDown(.RIGHT) {
			player_velocity.x = 400
			player_flip = false
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

		// we need this as decimal not integer, so the cast
		player_run_width := f32(player_run_texture.width)
		player_run_height := f32(player_run_texture.height)

		// add timer 
		player_run_frame_timer += rl.GetFrameTime()

		// change frame based on timer
		for player_run_frame_timer > player_run_frame_length {
			player_run_current_frame += 1 % player_run_num_frames
			player_run_frame_timer -= player_run_frame_length
		}

		// source rect, changing texture
		draw_player_source := rl.Rectangle {
			x      = f32(player_run_current_frame) * player_run_width / f32(player_run_num_frames),
			y      = 0,
			width  = player_run_width / f32(player_run_num_frames), // width of single frame
			height = player_run_height,
		}

		if player_flip {
			draw_player_source.width = -draw_player_source.width // how do this work?
		}

		// destination rect on screen
		draw_player_dest := rl.Rectangle {
			x      = player_pos.x,
			y      = player_pos.y,
			width  = player_run_width * 4 / f32(player_run_num_frames),
			height = player_run_height * 4,
		}

		// create a rectangle using vector
		// rl.DrawRectangleV(player_pos, player_size, rl.WHITE)

		// rl.DrawTextureEx(player_run_texture, player_pos, 0, 4, rl.WHITE) // with scaling by 4

		rl.DrawTexturePro(player_run_texture, draw_player_source, draw_player_dest, 0, 0, rl.WHITE)

		rl.EndDrawing()
	}

	rl.CloseWindow()
}
