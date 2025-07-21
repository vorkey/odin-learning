package raylib_game

import rl "vendor:raylib"

Animation :: struct {
	texture:       rl.Texture2D,
	name:          Animation_Name,
	num_frames:    int,
	frame_timer:   f32,
	current_frame: int,
	frame_length:  f32,
}

Animation_Name :: enum {
	Idle,
	Run,
}

update_animation :: proc(a: ^Animation) {
	// add timer 
	a.frame_timer += rl.GetFrameTime()

	// change frame based on timer
	for a.frame_timer > a.frame_length {
		a.current_frame += 1 % a.num_frames
		a.frame_timer -= a.frame_length
	}
}


draw_animation :: proc(a: Animation, pos: rl.Vector2, flip: bool) {
	// we need this as decimal not integer, and so the cast
	a_width := f32(a.texture.width)
	a_height := f32(a.texture.height)

	// source rect, changing texture
	source := rl.Rectangle {
		x      = f32(a.current_frame) * a_width / f32(a.num_frames),
		y      = 0,
		width  = a_width / f32(a.num_frames), // width of single frame
		height = a_height,
	}

	if flip {
		source.width = -source.width // how do this work?
	}

	// destination rect on screen
	dest := rl.Rectangle {
		x      = pos.x,
		y      = pos.y,
		width  = a_width / f32(a.num_frames),
		height = a_height,
	}

	// create a rectangle using vector
	// rl.DrawRectangleV(player_pos, player_size, rl.WHITE)

	// rl.DrawTextureEx(player_run_texture, player_pos, 0, 4, rl.WHITE) // with scaling by 4

	// draw to a Rect and change the origin to middle bottom from top left
	rl.DrawTexturePro(a.texture, source, dest, {dest.width / 2, dest.height}, 0, rl.WHITE)
}

PixelWindowHeight :: 180

main :: proc() {
	rl.InitWindow(1280, 720, "Hello Raylib")
	rl.SetWindowState({.WINDOW_RESIZABLE})
	rl.SetTargetFPS(480)

	player_pos: rl.Vector2 // x, y
	player_size := rl.Vector2{64, 64}
	player_velocity: rl.Vector2
	player_grounded: bool
	player_flip: bool

	player_run := Animation {
		texture      = rl.LoadTexture("plae.png"),
		name         = .Run,
		num_frames   = 4,
		// frame_timer   = 0, // 0 initialized
		// current_frame = 0,
		frame_length = 0.1, // since we don't want this to happen each fps
	}

	player_idle := Animation {
		texture      = rl.LoadTexture("plae_idle.png"),
		name         = .Idle,
		num_frames   = 2,
		frame_length = 0.5,
	}

	current_anim := player_idle

	platforms := []rl.Rectangle{{-20, 20, 96, 16}, {90, -10, 96, 16}, {180, -30, 96, 16}}

	platform_texture := rl.LoadTexture("plat.png")

	// main loop
	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground(rl.VIOLET)

		// velocity based horizontal movement
		if rl.IsKeyDown(.LEFT) {
			player_velocity.x = -100
			player_flip = true
			if current_anim.name != .Run {
				current_anim = player_run
			}
		} else if rl.IsKeyDown(.RIGHT) {
			player_velocity.x = 100
			player_flip = false
			if current_anim.name != .Run {
				current_anim = player_run
			}
		} else {
			player_velocity.x = 0
			if current_anim.name != .Idle {
				current_anim = player_idle
			}
		}

		player_velocity.y += 1000 * rl.GetFrameTime()

		if player_grounded && rl.IsKeyPressed(.SPACE) {
			player_velocity.y = -300 // goes upward, (0,0) on top left
		}

		// adding vector
		player_pos += player_velocity * rl.GetFrameTime() // move at 400 pixels/second, delta time included?

		// // disallow player falling through screen
		// if player_pos.y > f32(rl.GetScreenHeight()) - player_size.y {
		// 	player_pos.y = f32(rl.GetScreenHeight()) - player_size.y
		// 	player_grounded = true
		// }

		player_feet_collider := rl.Rectangle{player_pos.x - 3, player_pos.y - 1, 7, 1}

		player_grounded = false

		for platform in platforms {
			if rl.CheckCollisionRecs(player_feet_collider, platform) && player_velocity.y > 0 {
				player_velocity.y = 0
				player_pos.y = platform.y
				player_grounded = true
			}
		}


		update_animation(&current_anim)

		screen_height := f32(rl.GetScreenHeight())

		camera := rl.Camera2D {
			zoom   = screen_height / PixelWindowHeight,
			offset = {f32(rl.GetScreenWidth() / 2), screen_height / 2},
			target = player_pos,
		}

		rl.BeginMode2D(camera)
		draw_animation(current_anim, player_pos, player_flip)

		for platform in platforms do rl.DrawTextureV(platform_texture, {platform.x, platform.y}, rl.WHITE)

		// rl.DrawRectangleRec(player_feet_collider)
		rl.EndMode2D()

		rl.EndDrawing()
	}

	rl.CloseWindow()
}
