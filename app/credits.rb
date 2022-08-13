def show_credits args
  start_names_mid_x = 1280 / 2 - 52
  start_names_left_x = 1280 / 2 - 352
  start_names_right_x = 1280 / 2 + 248
  start_names_top = 500
  args.outputs.sprites << {
    path: "sprites/test_bg.png",
    x: 0,
    y: 0,
    w: 1280,
    h: 720
  }

  args.outputs.labels << {
    x: 1280 / 2,
    y: 600,
    r: 255,
    g: 255,
    b: 255,
    font: Constants::FONT,
    alignment_enum: 1,
    size_enum: Constants::FONT_SIZE_B,
    text: "Credits"}

  # GAME DESIGN
  args.outputs.labels << {
    x: start_names_mid_x,
    y: start_names_top,
    r: 255,
    g: 255,
    b: 255,
    font: Constants::FONT,
    alignment_enum: 0,
    size_enum: Constants::FONT_SIZE_S,
    text: "Game Design"}

  args.outputs.labels << {
    x: start_names_mid_x,
    y: start_names_top - 30,
    r: 255,
    g: 255,
    b: 255,
    font: Constants::FONT,
    alignment_enum: 0,
    size_enum: Constants::FONT_SIZE_M,
    text: "Daria Held"}

  args.outputs.labels << {
    x: start_names_mid_x,
    y: start_names_top - 65,
    r: 255,
    g: 255,
    b: 255,
    font: Constants::FONT,
    alignment_enum: 0,
    size_enum: Constants::FONT_SIZE_M,
    text: "Tanja Aigner"}

  # PROGRAMMING
  args.outputs.labels << {
    x: start_names_left_x,
    y: start_names_top,
    r: 255,
    g: 255,
    b: 255,
    font: Constants::FONT,
    alignment_enum: 0,
    size_enum: Constants::FONT_SIZE_S,
    text: "Programming"}

  args.outputs.labels << {
    x: start_names_left_x,
    y: start_names_top - 30,
    r: 255,
    g: 255,
    b: 255,
    font: Constants::FONT,
    alignment_enum: 0,
    size_enum: Constants::FONT_SIZE_M,
    text: "Laurin Muth"}

  args.outputs.labels << {
    x: start_names_left_x,
    y: start_names_top - 65,
    r: 255,
    g: 255,
    b: 255,
    font: Constants::FONT,
    alignment_enum: 0,
    size_enum: Constants::FONT_SIZE_M,
    text: "Lea Muth"}

  # MUSIC / SOUNDS
  args.outputs.labels << {
    x: start_names_right_x,
    y: start_names_top,
    r: 255,
    g: 255,
    b: 255,
    font: Constants::FONT,
    alignment_enum: 0,
    size_enum: Constants::FONT_SIZE_S,
    text: "Music/Sounds"}

  args.outputs.labels << {
    x: start_names_right_x,
    y: start_names_top - 30,
    r: 255,
    g: 255,
    b: 255,
    font: Constants::FONT,
    alignment_enum: 0,
    size_enum: Constants::FONT_SIZE_M,
    text: "Lorenz Lorenz"}

  args.outputs.labels << {
    x: 1280 / 2,
    y: 200,
    r: 255,
    g: 255,
    b: 255,
    font: Constants::FONT,
    alignment_enum: 1,
    size_enum: Constants::FONT_SIZE_S,
    text: "GameDev Regensburg Summer Game Jam 2022"}
end