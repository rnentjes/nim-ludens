import csfml as sfml
import math

import screen
import game

#

type
  ExampleScreen* = ref object of Screen
    time: float32

##

proc createScreen*(): ExampleScreen =
  result = ExampleScreen()


method Init*(screen: ExampleScreen) =
  screen.time = 0

method Update*(screen: ExampleScreen, delta: float32) =
  screen.time += delta

  var r,g,b: float32

  r = 0.5'f32 + math.sin(screen.time * 0.6) * 0.5'f32
  g = 0.5'f32 + math.sin(screen.time) * 0.5'f32
  b = 0.5'f32 + math.sin(screen.time * 1.4) * 0.5'f32

  ludens.SetClearColor(r, g, b)


### Create the game

var shooter = game.create(startScreen = createScreen(),
                          title = "Hello world",
                          vsync = true,
                          fullscreen = false,
                          width = 800,
                          height = 600)

shooter.SetOrthoWidth(800'f32)
shooter.Run()
