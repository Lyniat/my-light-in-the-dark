require 'app/credits.rb'

module Constants
  FISH_W = 556
  FISH_H = 515
  FISH_SCALE = 0.25
  FISH_SPEED = 3
  LIGHT_SIZE = 800
  FLICKER_SIZE = 40
  FONT = "fonts/AveriaLibre.ttf"
  FONT_SIZE_B = 10
  FONT_SIZE_M = 5
  FONT_SIZE_S = 1
  LIVES = 5
  GUI_LIVES_SCALE = 0.1
end

module State
  TITLE = 0
  GAME = 1
  CREDITS = 99
end

def tick args

  @state ||= 0
  @x ||= 0
  @y ||= 0
  @vector_x ||= 0
  @vector_y ||= 0
  @flipped ||= false
  @lives ||= Constants::LIVES

  @bullets ||= []

  if args.state.tick_count == 0
    args.audio[:bg_music] = {
      input: 'music/music_01.ogg',
      x: 0.0, y: 0.0, z: 0.0,
      gain: 0.5,
      pitch: 1.0,
      paused: false,
      looping: true,
    }
  end

  case @state
  when State::TITLE
    show_title args
  when State::GAME
    run_game args
    show_game_gui args
  when State::CREDITS
    show_credits args
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

  btn_credits_x = 1280 / 2 - (1037 * 0.15) / 2
  btn_credits_y = 50
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
    end

    if start_hovered
      @state = State::GAME
    end
  end
end

def run_game args
  fish_mid_x = (Constants::FISH_W * Constants::FISH_SCALE) / 2
  fish_mid_y = (Constants::FISH_H * Constants::FISH_SCALE) / 2

  if args.state.tick_count % 20 == 0
    start_x = rand(1280)
    start_y = rand(2) == 0 ? 720 + 190 : 0 -190

    vector_bullet_x = (@x + fish_mid_x) - start_y
    vector_bullet_y = (@y + fish_mid_y) - start_y

    vector_bullet_v = Math.sqrt((vector_bullet_x ** 2) + (vector_bullet_y ** 2))

    vector_bullet_x /= vector_bullet_v
    vector_bullet_y /= vector_bullet_v

    bullet = {x: start_x, y: start_y, dir_x: vector_bullet_x, dir_y: vector_bullet_y, speed: 2}
    @bullets << bullet
  end

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
  args.outputs[:lights].background_color = [0, 0, 0, 0]#[117, 176, 185, 0]

  light_flicker = Math.sin(args.state.tick_count / 20) * Constants::FLICKER_SIZE
  light_flicker -= Math.sin(args.state.tick_count / 13) * (Constants::FLICKER_SIZE / 3)

  args.outputs[:lights].sprites << { x: @x - Constants::LIGHT_SIZE / 2 + (Constants::FISH_W * Constants::FISH_SCALE) / 2 - light_flicker / 2,
                                     y: @y - Constants::LIGHT_SIZE / 2 + (Constants::FISH_H * Constants::FISH_SCALE) / 2 - light_flicker / 2,
                                     w: Constants::LIGHT_SIZE + light_flicker,
                                     h: Constants::LIGHT_SIZE + light_flicker,
                                     path: "sprites/mask.png" }


  frames_fish = ["00", "01", "02", "03", "02", "01"]
  args.outputs[:scene].background_color = [117, 176, 185, 255]

  args.outputs[:scene].sprites << {
    path: "sprites/test_bg.png",
    x: 0,
    y: 0,
    w: 1280,
    h: 720
  }

  frame = (args.state.tick_count / 20).floor % 6
  args.outputs[:scene].sprites << {
    path: "sprites/fish_light_#{frames_fish[frame]}.png",
    x: @x,
    y: @y,
    w: Constants::FISH_W * Constants::FISH_SCALE,
    h: Constants::FISH_H * Constants::FISH_SCALE,
    flip_horizontally: @flipped
  }

  to_remove = []

  @bullets.each do |bullet|
    bullet[:x] += bullet[:dir_x] * bullet[:speed]
    bullet[:y] += bullet[:dir_y] * bullet[:speed]

    bx = bullet[:x]
    by = bullet[:y]

    if bx < -200 or bx > 1280 + 200 or by < -200 or by > 720 + 200
      to_remove << bullet
    end

    args.outputs[:scene].sprites << {
      path: "sprites/lyniat.png",
      x: bx,
      y: by,
      w: 50,
      h: 50
    }

    if Math.sqrt(((@x + fish_mid_x) - (bx + 25)) ** 2 + ((@y + fish_mid_y) - (by + 25)) ** 2) < 70
      to_remove << bullet
      @lives -= 1
    end

  end

  @bullets -= to_remove

  args.outputs[:lighted_scene].sprites << { x: 0, y: 0, w: 1280, h: 720, path: :lights, blendmode_enum: 0 }
  args.outputs[:lighted_scene].sprites << { blendmode_enum: 2, x: 0, y: 0, w: 1280, h: 720, path: :scene }

  # output lighted scene to main canvas
  args.outputs.background_color = [0, 0, 0, 0]
  args.outputs.sprites << { x: 0, y: 0, w: 1280, h: 720, path: :lighted_scene }
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