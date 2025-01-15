package game

import rl "vendor:raylib"
import "core:math/rand"

Vector2 :: [2]i32
WINDOW_SIZE :: 400
GRID_SIZE :: 10
GS :: WINDOW_SIZE/GRID_SIZE

Player :: struct {
    pos: Vector2,
    dir: Vector2,
    tail: [dynamic]Vector2
}

player: Player
food: Vector2

init_player :: proc() -> () {
    start_pos := Vector2 {GRID_SIZE/2, GRID_SIZE/2}
    start_dir := Vector2 {0, 0}
    start_tail: [dynamic]Vector2
    i := 0
    for i < 3 {
        append(&start_tail, Vector2 {GRID_SIZE/2, GRID_SIZE/2})
        i+=1
    }
    delete(player.tail)
    player = Player {
        pos = start_pos,
        dir = start_dir,
        tail = start_tail
    }
}

init_food :: proc() -> () {
    bad_position := true
    for bad_position {
        bad_position = false
        random_x := rand.int31_max(GRID_SIZE)
        random_y := rand.int31_max(GRID_SIZE)
        food = Vector2 {random_x, random_y}
        for i := 0; i < len(player.tail); i+=1 {
            if player.tail[i][0] == food[0] && player.tail[i][1] == food[1] {
                bad_position = true
                break
            }
        }
    }
}

main :: proc() {
    rl.InitWindow(WINDOW_SIZE, WINDOW_SIZE, "Snake")
    rl.SetTargetFPS(10)

    init_player()
    init_food()

    for !rl.WindowShouldClose() {
        rl.BeginDrawing()
        rl.ClearBackground(rl.YELLOW)

        if rl.IsKeyDown(rl.KeyboardKey.A) {
            player.dir[0] = -1
            player.dir[1] = 0
        } else if rl.IsKeyDown(rl.KeyboardKey.W) {
            player.dir[0] = 0
            player.dir[1] = -1
        } else if rl.IsKeyDown(rl.KeyboardKey.D) {
            player.dir[0] = 1
            player.dir[1] = 0
        } else if rl.IsKeyDown(rl.KeyboardKey.S) {
            player.dir[0] = 0
            player.dir[1] = 1
        }

        for i := len(player.tail)-1; i > 0; i-=1 {
            player.tail[i][0] = player.tail[i-1][0]
            player.tail[i][1] = player.tail[i-1][1]
        }
        player.tail[0][0] = player.pos[0]
        player.tail[0][1] = player.pos[1]

        player.pos += player.dir
        if player.pos[0] >= GRID_SIZE {
            player.pos[0] = 0
        }
        if player.pos[1] >= GRID_SIZE {
            player.pos[1] = 0
        }
        if player.pos[0] < 0 {
            player.pos[0] = GRID_SIZE-1;
        }
        if player.pos[1] < 0 {
            player.pos[1] = GRID_SIZE-1;
        }

        for i := 0; i < len(player.tail); i+=1 {
            if player.pos[0] == player.tail[i][0] && player.pos[1] == player.tail[i][1] {
                init_player()
            }
        }

        if player.pos[0] == food[0] && player.pos[1] == food[1] {
            init_food()
            append(&player.tail, Vector2 {player.pos[0], player.pos[1]})
        }

        rl.DrawRectangle(player.pos[0]*GS, player.pos[1]*GS, GS, GS, rl.GREEN)
        for i := 0; i < len(player.tail); i+=1 {
            rl.DrawRectangle(player.tail[i][0]*GS, player.tail[i][1]*GS, GS, GS, rl.GREEN)
        }

        rl.DrawRectangle(food[0]*GS, food[1]*GS, GS, GS, rl.RED)

        rl.EndDrawing()
    }

    rl.CloseWindow()
}