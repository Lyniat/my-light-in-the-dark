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
    text: "Lorenz Heckelbacher"}

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

  btn_back_x = 1280 / 2 - (1037 * 0.15) / 2
  btn_back_y = 50
  btn_back_width = 1037 * 0.15
  btn_back_height = 282 * 0.15

  back_hovered = args.inputs.mouse.inside_rect?({   x: btn_back_x,
                                                    y: btn_back_y,
                                                    w: btn_back_width,
                                                    h: btn_back_height})

  back_sprite = back_hovered ? "sprites/gui/btn_back_hover.png" : "sprites/gui/btn_back.png"
  args.outputs.sprites << {
    x: btn_back_x,
    y: btn_back_y,
    w: btn_back_width,
    h: btn_back_height,
    path: back_sprite }

  if args.inputs.mouse.click
    if back_hovered
      @state = State::TITLE
      args.outputs.sounds << 'sounds/click.wav'
    end
  end
end