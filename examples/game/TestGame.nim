import screen
import game
import opengl as gl

import "screen/splash"

#

var
  theGame*: Game
  splashScreen*: Screen = splash.create()

##


theGame = game.create(startScreen = splashScreen, fullscreen = false, width = 960, height = 540)
theGame.SetOrthoHeight(1000'f32)
#theGame.Perspective(75'f32, 3'f32, 10'f32)
theGame.Run()
