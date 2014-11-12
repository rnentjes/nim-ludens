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

import cube

#

type
  ExampleScreen* = ref object of Screen
    font: Font
    time: float32
    number: int
    cube: Cuber
    showInfo: bool


##

proc createScreen*(): ExampleScreen =
  result = ExampleScreen()
  result.number = 5


method Init*(screen: ExampleScreen) =
  screen.time = 0

  screen.font = createFont("data/fonts/COMPUTERRobot.ttf", color(255,100,0))
  screen.cube = createCuber()

  screen.showInfo = true


method Dispose*(screen: ExampleScreen) =
  screen.font.Dispose()


method Update*(screen: ExampleScreen, delta: float32) =
  screen.time += delta / 4


method Render*(screen: ExampleScreen) =
  var x = 0'f32
  var y = 0'f32
  var d = 0'f32
  var dd = 1000'f32 / float32(screen.number)
  var r = 0'f32
  var rd = 5'f32 / float32(screen.number)
  var z = 0'f32


  for i in countup(1, screen.number):
    r += rd
    d += dd
    x = sin(screen.time * 5 + d) * r
    y = cos(screen.time * 7 + d) * r
    z = -5 + sin(screen.time * 7 + d) * r

    screen.cube.draw(x, y, z, 0.025, x, y, z)

  #screen.cube.draw(0, -0.5, -4, 0.3, 0, y, x)
  #screen.cube.draw(0.5, 0, -2, 0.2, x, y, 0)
  screen.cube.flush()

  # actual draw call!
  #screen.txt.flush()

  if screen.showInfo:
    screen.font.SetColor(color(255, 255, 255, 255))
    screen.font.DrawCentered("Cubes: " & $screen.number, 32, 0'f32, 0'f32)

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

  if key == sfml.KeyI:
    screen.showInfo = not screen.showInfo

  screen.number = max(screen.number, 5)


### Create the game

var shooter = game.create(startScreen = createScreen(),
                          title = "3D Cubes",
                          vsync = false,
                          fullscreen = false,
                          width = 800,
                          height = 600)

shooter.SetClearColor(color(40, 40, 40))
# this sets orthographic project used by fonts
shooter.SetOrthoWidth(800'f32)
# perspective settings doesn't overwrite font view
shooter.Perspective(60'f32, 1'f32, 50'f32)
shooter.Run()
