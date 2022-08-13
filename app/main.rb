module Constants
  FISH_W = 556
  FISH_H = 515
  FISH_SCALE = 0.25
  FISH_SPEED = 3
  LIGHT_SIZE = 800
  FLICKER_SIZE = 40
end

def tick args

  @x ||= 0
  @y ||= 0
  @vector_x ||= 0
  @vector_y ||= 0
  @flipped ||= false

  @bullets ||= []

  #if args.state.tick_count == 0
  #  @bullets << {x: 400, y: 400, dir_x: 1, dir_y: 1, speed: 0.1}
  #end

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
    end

  end

  @bullets -= to_remove

  args.outputs[:lighted_scene].sprites << { x: 0, y: 0, w: 1280, h: 720, path: :lights, blendmode_enum: 0 }
  args.outputs[:lighted_scene].sprites << { blendmode_enum: 2, x: 0, y: 0, w: 1280, h: 720, path: :scene }

  # output lighted scene to main canvas
  args.outputs.background_color = [0, 0, 0, 0]
  args.outputs.sprites << { x: 0, y: 0, w: 1280, h: 720, path: :lighted_scene }

end