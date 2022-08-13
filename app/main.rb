module Constants
  FISH_W = 556
  FISH_H = 515
  FISH_SCALE = 0.25
end

def tick args
  frames_fish = ["00", "01", "02", "03", "02", "01"]
  args.outputs.background_color = [117, 176, 185]
  frame = (args.state.tick_count / 20).floor % 6
  args.outputs.sprites << {
    path: "sprites/fish_light_#{frames_fish[frame]}.png",
    x: 0,
    y: 0,
    w: Constants::FISH_W * 0.25,
    h: Constants::FISH_H * 0.25
  }
end