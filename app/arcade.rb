def run_arcade args
  @arcade_time += 1

  @animation_timer -= 1
  if @animation_timer <= 0
    @animation_timer = 0
    @animation_state = Animation::LIGHT
  end

  fish_mid_x = (Constants::FISH_W * Constants::FISH_SCALE) / 2
  fish_mid_y = (Constants::FISH_H * Constants::FISH_SCALE) / 2

  # bullets
  if args.state.tick_count % 40 == 0
    start_x = rand(1280)
    start_y = rand(2) == 0 ? 720 + 190 : 0 -190

    type = rand(2) == 0 ? "00" : "01"

    vector_bullet_x = (@x + fish_mid_x) - start_y
    vector_bullet_y = (@y + fish_mid_y) - start_y

    vector_bullet_v = Math.sqrt((vector_bullet_x ** 2) + (vector_bullet_y ** 2))

    vector_bullet_x /= vector_bullet_v
    vector_bullet_y /= vector_bullet_v

    bullet = {x: start_x, y: start_y, dir_x: vector_bullet_x, dir_y: vector_bullet_y, speed: 1 + @level, angle: 0, type: type, time: 0}
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

    @x += @vector_x * Constants::FISH_SPEED_ARCADE
    @y += @vector_y * Constants::FISH_SPEED_ARCADE
  end

  @flipped = @vector_x < 0

  # render light
  light_intensity = 255 - (@arcade_time / 6).round
  if light_intensity < 0
    light_intensity = 0
  end
  args.outputs[:lights].background_color = [0, 0, 0, light_intensity]

  light_flicker = Math.sin(args.state.tick_count / 20) * Constants::FLICKER_SIZE
  light_flicker -= Math.sin(args.state.tick_count / 13) * (Constants::FLICKER_SIZE / 3)

  args.outputs[:lights].sprites << { x: @x - Constants::LIGHT_SIZE / 4 + (Constants::FISH_W * Constants::FISH_SCALE) / 2 - light_flicker / 2,
                                     y: @y - Constants::LIGHT_SIZE / 4 + (Constants::FISH_H * Constants::FISH_SCALE) / 2 - light_flicker / 2,
                                     w: Constants::LIGHT_SIZE / 2 + light_flicker,
                                     h: Constants::LIGHT_SIZE / 2 + light_flicker,
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

  @bullets.each do |bullet|
    bx = bullet[:x]
    by = bullet[:y]

    args.outputs[:lights].sprites << {
      path: "sprites/mask_blue.png",
      x: bx - 75,
      y: by - 75,
      w: 200,
      h: 200,
    }
  end


  #frames_fish = ["00", "01", "02", "03", "02", "01"]
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

  bg_path = "sprites/background/lvl_01.png"
  bg_fg_path = "sprites/background/lvl_01_plants.png"

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
    time = bullet[:time]
    speed = @arcade_time / 600
    if speed > 5
      speed = 5
    end
    bullet[:x] += Math.sin(time / 60) * 2
    bullet[:y] += Math.cos(time / 60) * 2
    bullet[:x] += bullet[:dir_x] * speed
    bullet[:y] += bullet[:dir_y] * speed

    bullet[:angle] += 1
    bullet[:time] += 1

    bx = bullet[:x]
    by = bullet[:y]

    if bx < -400 or bx > 1280 + 400 or by < -400 or by > 720 + 400
      bullets_to_remove << bullet
    end

    args.outputs[:scene].sprites << {
      path: "sprites/mask_blue_2.png",
      x: bx - 75,
      y: by - 75,
      w: 200,
      h: 200,
    }

    args.outputs[:scene].sprites << {
      path: "sprites/energy/neg_inv.png",
      x: bx,
      y: by,
      w: 50,
      h: 50,
      angle: bullet[:angle]
    }

    if Math.sqrt(((@x + fish_mid_x) - (bx + 25)) ** 2 + ((@y + fish_mid_y) - (by + 25)) ** 2) < 70
      bullets_to_remove << bullet
      @last_score = @arcade_points
      reset_game args
      @state = State::GAME_OVER
      args.outputs.sounds << 'sounds/bubbles.wav'
      @animation_state = Animation::SAD
      @animation_timer = Constants::ANIMATION_TIME
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
      @arcade_points += 100
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

  args.outputs.labels << {
    x: 20,
    y: 720 - 20,
    r: 255,
    g: 255,
    b: 255,
    font: Constants::FONT,
    alignment_enum: 0,
    size_enum: Constants::FONT_SIZE_B,
    text: "SCORE: #{@arcade_points}"}
end