module Constants
  FISH_W = 556
  FISH_H = 515
  FISH_SCALE = 0.25
  FISH_SPEED = 3
end

def tick args

  @x ||= 0
  @y ||= 0
  @vector_x ||= 0
  @vector_y ||= 0
  @flipped ||= false

  fish_mid_x = (Constants::FISH_W * Constants::FISH_SCALE) / 2
  fish_mid_y = (Constants::FISH_W * Constants::FISH_SCALE) / 2

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

  frames_fish = ["00", "01", "02", "03", "02", "01"]
  args.outputs.background_color = [117, 176, 185]
  frame = (args.state.tick_count / 20).floor % 6
  args.outputs.sprites << {
    path: "sprites/fish_light_#{frames_fish[frame]}.png",
    x: @x,
    y: @y,
    w: Constants::FISH_W * Constants::FISH_SCALE,
    h: Constants::FISH_H * Constants::FISH_SCALE,
    flip_horizontally: @flipped
  }

end