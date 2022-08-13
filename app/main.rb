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

  fish_mid_x = (Constants::FISH_W * Constants::FISH_SCALE) / 2
  fish_mid_y = (Constants::FISH_H * Constants::FISH_SCALE) / 2

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

  args.outputs[:lighted_scene].sprites << { x: 0, y: 0, w: 1280, h: 720, path: :lights, blendmode_enum: 0 }
  args.outputs[:lighted_scene].sprites << { blendmode_enum: 2, x: 0, y: 0, w: 1280, h: 720, path: :scene }

  # output lighted scene to main canvas
  args.outputs.background_color = [0, 0, 0, 0]
  args.outputs.sprites << { x: 0, y: 0, w: 1280, h: 720, path: :lighted_scene }

end