import csfml as sfml
import csfml
import opengl as gl
import math
import strutils

import screen
import game
import texture
import font
import music

#

type
  ExampleScreen* = ref object of Screen
    font: Font
    time: float32
    txt: Texture
    number: int

##

proc createScreen*(): ExampleScreen =
  result = ExampleScreen()
  result.number = 5


method Init*(screen: ExampleScreen) =
  screen.time = 0

  screen.font = createFont("data/fonts/COMPUTERRobot.ttf", color(255,100,0))

  screen.txt = createTexture("data/images/ufoRed.png")


method Dispose*(screen: ExampleScreen) =
  screen.font.Dispose()
  screen.txt.Dispose()


method Update*(screen: ExampleScreen, delta: float32) =
  screen.time += delta / 4


method Render*(screen: ExampleScreen) =
  var x = 0'f32
  var y = 0'f32
  var d = 0'f32
  var r = 0'f32

  for i in countup(1, screen.number):
    r += 0.2
    d += 3
    x = sin(screen.time + d) * r
    y = cos(screen.time + d) * r

    screen.txt.draw(x, y, 25, 25)

  # actual draw call!
  screen.txt.flush()

  screen.font.SetColor(color(255, 255, 255, 255))
  screen.font.DrawCentered("Textures: " & $screen.number, 32, 0'f32, 0'f32)

  screen.font.SetColor(color(0, 100, 255, 225))
  screen.font.DrawCentered("Try cursor keys...", 24, 0'f32, -100'f32)

  screen.font.SetColor(color(0, 0, 0, 225))
  screen.font.DrawCentered("FrameRate: " & formatFloat(ludens.GetFrameRate(), ffDefault, 4), 24, 0'f32, -150'f32)
  screen.font.DrawCentered("FrameTime: " & formatFloat(ludens.GetFrameTime(), ffDefault, 4), 24, 0'f32, -175'f32)


method KeyUp*(screen: ExampleScreen, key: TKeyCode) =
  var multiplier = 1.4
  if key == sfml.KeyLeft:
    screen.number = int(float(screen.number) / multiplier)

  if key == sfml.KeyRight:
    screen.number = int(float(screen.number) * multiplier)

  if key == sfml.KeyDown:
    screen.number = int(float(screen.number) / multiplier)

  if key == sfml.KeyUp:
    screen.number = int(float(screen.number) * multiplier)

  screen.number = max(screen.number, 5)


### Create the game

var shooter = game.create(startScreen = createScreen(),
                          title = "Draw Test",
                          vsync = false,
                          fullscreen = false,
                          width = 600,
                          height = 900)

shooter.SetClearColor(color(40, 40, 40))
shooter.SetOrthoHeight(900'f32)
shooter.Run()
