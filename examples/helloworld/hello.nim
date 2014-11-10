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

  var r,g,b: int

  r = 155 + int(math.sin(screen.time * 0.6) * 100)
  g = 155 + int(math.sin(screen.time) * 100)
  b = 155 + int(math.sin(screen.time * 1.4) * 100)

  ludens.SetClearColor(color(r, g, b))


### Create the game

var shooter = game.create(startScreen = createScreen(),
                          title = "Hello world",
                          vsync = true,
                          fullscreen = false,
                          width = 800,
                          height = 600)

shooter.SetOrthoWidth(800'f32)
shooter.Run()
