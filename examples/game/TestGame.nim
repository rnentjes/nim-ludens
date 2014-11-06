import screen
import game
import opengl as gl

import "screen/splash"

#

var
  theGame*: Game

##


theGame = game.create(startScreen = splash.create())
theGame.SetOrthoHeight(1000'f32)
#theGame.Perspective(75'f32, 3'f32, 10'f32)
theGame.Run()
