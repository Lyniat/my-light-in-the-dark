require 'app/credits.rb'
require 'app/arcade.rb'

module Constants
  FISH_W = 556
  FISH_H = 515
  FISH_SCALE = 0.25
  FISH_SPEED = 4
  FISH_SPEED_ARCADE = 7
  LIGHT_SIZE = 1000
  FLICKER_SIZE = 40
  FONT = "fonts/AveriaLibre.ttf"
  FONT_SIZE_B = 10
  FONT_SIZE_M = 5
  FONT_SIZE_S = 1
  LIVES = 10
  GUI_LIVES_SCALE = 0.1
  ANIMATION_TIME = 2 * 60
end

module State
  TITLE = 0
  GAME = 1
  DIALOG = 2
  GAME_OVER = 3
  ARCADE = 4
  CREDITS = 99
end

module LevelState
  BLENDING = 0
  GAME = 1
  DIALOG = 2
end

module Animation
  LIGHT = 0
  EATING = 1
  SAD = 2
end

def reset_game args
  @x = 1280 / 2
  @y = 720 / 2
  @lives = Constants::LIVES / 2

  @bullets = []
  @gems = []
  @animation_state = Animation::LIGHT
  @animation_timer = 0
  @arcade_time = 0
  @arcade_points = 0
end

def tick args

  @state ||= 0
  @level ||= 0
  @vector_x ||= 0
  @vector_y ||= 0
  @flipped ||= false
  @animation_state ||= Animation::LIGHT
  @animation_timer ||= 0
  @last_score ||= 0

  # 08-08-2024 added for performance improvements
  args.outputs[:lights].transient!
  args.outputs[:scene].transient!
  args.outputs[:lighted_scene].transient!

  if args.state.tick_count == 0
    args.audio[:bg_music_0] = {
      input: 'music/music_01.ogg',
      x: 0.0, y: 0.0, z: 0.0,
      gain: 0.5,
      pitch: 1.0,
      paused: false,
      looping: true,
    }
    args.audio[:bg_music_1] = {
      input: 'music/music_02.ogg',
      x: 0.0, y: 0.0, z: 0.0,
      gain: 0,
      pitch: 1.0,
      paused: false,
      looping: true,
    }
    args.audio[:bg_music_2] = {
      input: 'music/music_03.ogg',
      x: 0.0, y: 0.0, z: 0.0,
      gain: 0,
      pitch: 1.0,
      paused: false,
      looping: true,
    }
  end

  # music
  args.audio[:bg_music_0][:gain] = @level == 0 ? 0.5 : 0
  args.audio[:bg_music_1][:gain] = @level == 1 ? 0.5 : 0
  args.audio[:bg_music_2][:gain] = @level >= 2 ? 0.5 : 0

  case @state
  when State::TITLE
    show_title args
  when State::GAME
    run_game args
    show_game_gui args
  when State::CREDITS
    show_credits args
  when State::DIALOG
    show_dialog args
  when State::ARCADE
    run_arcade args
  when State::GAME_OVER
    show_game_over args
  end

end

def show_title args
  args.outputs.sprites << {
    path: "sprites/test_bg.png",
    x: 0,
    y: 0,
    w: 1280,
    h: 720
  }
  args.outputs.sprites << {
    x: 230,
    y: 150,
    w: 902 * 0.75,
    h: 736* 0.75,
    path: "sprites/gui/title.png" }

  btn_start_x = 1280 / 2 - (1037 * 0.25) / 2
  btn_start_y = 150
  btn_start_width = 1037 * 0.25
  btn_start_height = 282 * 0.25

  start_hovered = args.inputs.mouse.inside_rect?({x: btn_start_x,
                                                   y: btn_start_y,
                                                   w: btn_start_width,
                                                   h: btn_start_height})

  start_sprite = start_hovered ? "sprites/gui/btn_start_hover.png" : "sprites/gui/btn_start.png"
  args.outputs.sprites << {
    x: btn_start_x,
    y: btn_start_y,
    w: btn_start_width,
    h: btn_start_height,
    path: start_sprite }

  btn_arcade_x = 1280 / 2 - (1037 * 0.15) / 2
  btn_arcade_y = 80
  btn_arcade_width = 1037 * 0.15
  btn_arcade_height = 282 * 0.15

  arcade_hovered = args.inputs.mouse.inside_rect?({x: btn_arcade_x,
                                                  y: btn_arcade_y,
                                                  w: btn_arcade_width,
                                                  h: btn_arcade_height})

  arcade_sprite = arcade_hovered ? "sprites/gui/btn_arcade_hover.png" : "sprites/gui/btn_arcade.png"
  args.outputs.sprites << {
    x: btn_arcade_x,
    y: btn_arcade_y,
    w: btn_arcade_width,
    h: btn_arcade_height,
    path: arcade_sprite }

  btn_credits_x = 1280 / 2 - (1037 * 0.15) / 2
  btn_credits_y = 10
  btn_credits_width = 1037 * 0.15
  btn_credits_height = 282 * 0.15

  credits_hovered = args.inputs.mouse.inside_rect?({x: btn_credits_x,
                                                    y: btn_credits_y,
                                                    w: btn_credits_width,
                                                    h: btn_credits_height})

  credits_sprite = credits_hovered ? "sprites/gui/btn_credits_hover.png" : "sprites/gui/btn_credits.png"
  args.outputs.sprites << {
    x: btn_credits_x,
    y: btn_credits_y,
    w: btn_credits_width,
    h: btn_credits_height,
    path: credits_sprite }

  if args.inputs.mouse.click
    if credits_hovered
      @state = State::CREDITS
      args.outputs.sounds << 'sounds/click.wav'
    end

    if start_hovered
      reset_game args
      @last_score = 0
      @state = State::DIALOG
      args.outputs.sounds << 'sounds/click.wav'
    end

    if arcade_hovered
      reset_game args
      @last_score = 0
      @state = State::ARCADE
      args.outputs.sounds << 'sounds/click.wav'
    end
  end
end

def run_game args
  @animation_timer -= 1
  if @animation_timer <= 0
    @animation_timer = 0
    @animation_state = Animation::LIGHT
  end

  fish_mid_x = (Constants::FISH_W * Constants::FISH_SCALE) / 2
  fish_mid_y = (Constants::FISH_H * Constants::FISH_SCALE) / 2

  # bullets
  if args.state.tick_count % 20 == 0
    start_x = rand(1280)
    start_y = rand(2) == 0 ? 720 + 190 : 0 -190

    type = rand(2) == 0 ? "00" : "01"

    vector_bullet_x = (@x + fish_mid_x) - start_y
    vector_bullet_y = (@y + fish_mid_y) - start_y

    vector_bullet_v = Math.sqrt((vector_bullet_x ** 2) + (vector_bullet_y ** 2))

    vector_bullet_x /= vector_bullet_v
    vector_bullet_y /= vector_bullet_v

    bullet = {x: start_x, y: start_y, dir_x: vector_bullet_x, dir_y: vector_bullet_y, speed: 1 + @level, angle: 0, type: type}
    @bullets << bullet
  end

  # gems
  if args.state.tick_count % 120 == 0
    start_x = rand(1280)
    start_y = rand(2) == 0 ? 720 + 190 : 0 -190

    type = rand(2) == 0 ? "00" : "01"

    vector_bullet_x = (@x + fish_mid_x) - start_y
    vector_bullet_y = (@y + fish_mid_y) - start_y

    vector_bullet_v = Math.sqrt((vector_bullet_x ** 2) + (vector_bullet_y ** 2))

    vector_bullet_x /= vector_bullet_v
    vector_bullet_y /= vector_bullet_v

    gem = {x: start_x, y: start_y, dir_x: vector_bullet_x, dir_y: vector_bullet_y, speed: 3, angle: 0, type: type}
    @gems << gem
  end

  # player
  @vector_x = args.inputs.mouse.x - (@x + fish_mid_x)
  @vector_y = args.inputs.mouse.y - (@y + fish_mid_y)

  vector_v = Math.sqrt((@vector_x ** 2) + (@vector_y ** 2))

  # don't divide with 0 // reduce jittering
  if vector_v.nonzero? and vector_v > 4
    @vector_x /= vector_v
    @vector_y /= vector_v

    @x += @vector_x * Constants::FISH_SPEED
    @y += @vector_y * Constants::FISH_SPEED
  end

  @flipped = @vector_x < 0

  # render light
  case @level
  when 0
    args.outputs[:lights].background_color = [0, 0, 0, 120]
  when 1
    args.outputs[:lights].background_color = [0, 0, 0, 40]
  else
    args.outputs[:lights].background_color = [0, 0, 0, 0]
  end

  light_flicker = Math.sin(args.state.tick_count / 20) * Constants::FLICKER_SIZE
  light_flicker -= Math.sin(args.state.tick_count / 13) * (Constants::FLICKER_SIZE / 3)

  args.outputs[:lights].sprites << { x: @x - Constants::LIGHT_SIZE / 2 + (Constants::FISH_W * Constants::FISH_SCALE) / 2 - light_flicker / 2,
                                     y: @y - Constants::LIGHT_SIZE / 2 + (Constants::FISH_H * Constants::FISH_SCALE) / 2 - light_flicker / 2,
                                     w: Constants::LIGHT_SIZE + light_flicker,
                                     h: Constants::LIGHT_SIZE + light_flicker,
                                     path: "sprites/mask.png" }

  @gems.each do |gem|
    bx = gem[:x]
    by = gem[:y]

    light_flicker = Math.sin(args.state.tick_count / 20) * Constants::FLICKER_SIZE
    args.outputs[:lights].sprites << {
      path: "sprites/mask.png",
      x: bx - 75 - light_flicker / 2,
      y: by - 75 -  light_flicker / 2,
      w: 200 + light_flicker,
      h: 200 + light_flicker,
    }
  end

  frames_fish = [
    "sprites/fish_light_00.png",
    "sprites/fish_light_01.png",
    "sprites/fish_light_02.png",
    "sprites/fish_light_03.png",
    "sprites/fish_light_02.png",
    "sprites/fish_light_01.png",
  ]
  frames_fish_sad = [
    "sprites/fish_sad_00.png",
    "sprites/fish_sad_01.png",
    "sprites/fish_sad_02.png",
    "sprites/fish_sad_03.png",
    "sprites/fish_sad_02.png",
    "sprites/fish_sad_01.png",
  ]
  frames_fish_eating = [
    "sprites/fish_light_00.png",
    "sprites/fish_eating_00.png",
    "sprites/fish_eating_01.png",
    "sprites/fish_eating_02.png",
    "sprites/fish_eating_01.png",
    "sprites/fish_eating_00.png",
  ]
  args.outputs[:scene].background_color = [117, 176, 185, 255]

  case @level
  when 0
    bg_path = "sprites/background/lvl_00.png"
    bg_fg_path = "sprites/background/lvl_00_plants.png"
  when 1
    bg_path = "sprites/background/lvl_01.png"
    bg_fg_path = "sprites/background/lvl_01_plants.png"
  else
    bg_path = "sprites/background/lvl_02.png"
    bg_fg_path = "sprites/background/lvl_02_plants.png"
  end

  args.outputs[:scene].sprites << {
    path: bg_path,
    x: 0,
    y: 0,
    w: 1280,
    h: 720
  }

  case @animation_state
  when Animation::SAD
    animation_array = frames_fish_sad
  when Animation::EATING
    animation_array = frames_fish_eating
  else
    animation_array = frames_fish
  end

  frame = (args.state.tick_count / 20).floor % 6
  args.outputs[:scene].sprites << {
    path: animation_array[frame],
    x: @x,
    y: @y,
    w: Constants::FISH_W * Constants::FISH_SCALE,
    h: Constants::FISH_H * Constants::FISH_SCALE,
    flip_horizontally: @flipped
  }

  bullets_to_remove = []
  gems_to_remove = []

  @bullets.each do |bullet|
    bullet[:x] += bullet[:dir_x] * bullet[:speed]
    bullet[:y] += bullet[:dir_y] * bullet[:speed]

    bullet[:angle] += 1

    bx = bullet[:x]
    by = bullet[:y]

    if bx < -200 or bx > 1280 + 200 or by < -200 or by > 720 + 200
      bullets_to_remove << bullet
    end

    args.outputs[:scene].sprites << {
      path: "sprites/energy/neg_#{bullet[:type]}.png",
      x: bx,
      y: by,
      w: 50,
      h: 50,
      angle: bullet[:angle]
    }

    if Math.sqrt(((@x + fish_mid_x) - (bx + 25)) ** 2 + ((@y + fish_mid_y) - (by + 25)) ** 2) < 70
      bullets_to_remove << bullet
      @lives -= 1
      @animation_state = Animation::SAD
      @animation_timer = Constants::ANIMATION_TIME
      args.outputs.sounds << 'sounds/hurt.wav'
    end

  end

  @gems.each do |gem|
    gem[:angle] += 1

    bx = gem[:x]
    by = gem[:y]

    if bx < -200 or bx > 1280 + 200 or by < -200 or by > 720 + 200
      gems_to_remove << gem
    end

    args.outputs[:scene].sprites << {
      path: "sprites/energy/pos_#{gem[:type]}.png",
      x: bx,
      y: by,
      w: 50,
      h: 50,
      angle: gem[:angle]
    }

    if Math.sqrt(((@x + fish_mid_x) - (bx + 25)) ** 2 + ((@y + fish_mid_y) - (by + 25)) ** 2) < 70
      gems_to_remove << gem
      @lives += 1
      @animation_state = Animation::EATING
      @animation_timer = Constants::ANIMATION_TIME
      args.outputs.sounds << 'sounds/eat.wav'
    end

    gem[:x] += gem[:dir_x] * gem[:speed]
    gem[:y] += gem[:dir_y] * gem[:speed]
  end

  @bullets -= bullets_to_remove
  @gems -= gems_to_remove

  args.outputs[:scene].sprites << {
    path: bg_fg_path,
    x: 0,
    y: 0,
    w: 1280,
    h: 720
  }

  args.outputs[:lighted_scene].sprites << { x: 0, y: 0, w: 1280, h: 720, path: :lights, blendmode_enum: 0 }
  args.outputs[:lighted_scene].sprites << { blendmode_enum: 2, x: 0, y: 0, w: 1280, h: 720, path: :scene }

  # output lighted scene to main canvas
  args.outputs.background_color = [0, 0, 0, 0]
  args.outputs.sprites << { x: 0, y: 0, w: 1280, h: 720, path: :lighted_scene }

  if @lives >= Constants::LIVES
    reset_game args
    @level += 1
    @state = State::DIALOG
  end

  if @lives <= 0
    reset_game args
    @state = State::GAME_OVER
    args.outputs.sounds << 'sounds/bubbles.wav'
  end
end

def show_game_gui args
  i = 0

  while i < Constants::LIVES
    args.outputs.sprites << {
      path: "sprites/gui/light_off.png",
      x: i * 299 * Constants::GUI_LIVES_SCALE + 20 + i * 20,
      y: 720 - 388 * Constants::GUI_LIVES_SCALE - 20,
      w: 299 * Constants::GUI_LIVES_SCALE,
      h: 388 * Constants::GUI_LIVES_SCALE
    }
    i += 1
  end

  i = 0

  while i < @lives
    args.outputs.sprites << {
      path: "sprites/gui/light_on.png",
      x: i * 299 * Constants::GUI_LIVES_SCALE + 20 + i * 20,
      y: 720 - 388 * Constants::GUI_LIVES_SCALE - 20,
      w: 299 * Constants::GUI_LIVES_SCALE,
      h: 388 * Constants::GUI_LIVES_SCALE
    }
    i += 1
  end
end

def show_dialog args
  case @level
  when 0
    bg_path = "sprites/dialog/dialog_0.png"
  when 1
    bg_path = "sprites/dialog/dialog_1.png"
  when 2
    bg_path = "sprites/dialog/dialog_2.png"
  else
    bg_path = "sprites/dialog/dialog_3.png"
  end

  args.outputs.sprites << {
    path: bg_path,
    x: 0,
    y: 0,
    w: 1280,
    h: 720
  }

  btn_start_x = 1280 / 2 - (1037 * 0.25) / 2
  btn_start_y = 50
  btn_start_width = 1037 * 0.25
  btn_start_height = 282 * 0.25

  continue_hovered = args.inputs.mouse.inside_rect?({x: btn_start_x,
                                                    y: btn_start_y,
                                                    w: btn_start_width,
                                                    h: btn_start_height})

  continue_sprite = continue_hovered ? "sprites/gui/btn_continue_hover.png" : "sprites/gui/btn_continue.png"
  args.outputs.sprites << {
    x: btn_start_x,
    y: btn_start_y,
    w: btn_start_width,
    h: btn_start_height,
    path: continue_sprite }

  if args.inputs.mouse.click
    if continue_hovered
      if @level < 3
        @state = State::GAME
      else
        @level = 0
        @state = State::TITLE
      end
      args.outputs.sounds << 'sounds/click.wav'
    end
  end
end

def show_game_over args
  args.outputs.sprites << {
    path: "sprites/gui/game_over.png",
    x: 0,
    y: 0,
    w: 1280,
    h: 720
  }

  btn_start_x = 1280 / 2 - (1037 * 0.25) / 2
  btn_start_y = 50
  btn_start_width = 1037 * 0.25
  btn_start_height = 282 * 0.25

  continue_hovered = args.inputs.mouse.inside_rect?({x: btn_start_x,
                                                     y: btn_start_y,
                                                     w: btn_start_width,
                                                     h: btn_start_height})

  continue_sprite = continue_hovered ? "sprites/gui/btn_retry_hover.png" : "sprites/gui/btn_retry.png"
  args.outputs.sprites << {
    x: btn_start_x,
    y: btn_start_y,
    w: btn_start_width,
    h: btn_start_height,
    path: continue_sprite }

  if @last_score > 0
    args.outputs.labels << {
      x: 1280 / 2,
      y: 220,
      r: 255,
      g: 255,
      b: 255,
      font: Constants::FONT,
      alignment_enum: 1,
      size_enum: Constants::FONT_SIZE_B,
      text: "Your score: #{@last_score}"}
  end

  if args.inputs.mouse.click
    if continue_hovered
      reset_game args
      @state = State::TITLE
      @level = 0
      args.outputs.sounds << 'sounds/click.wav'
    end
  end
end