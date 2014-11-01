import screen
import game
import opengl as gl
import sprites as spr

import "screen/splash"

#

var
  theGame: Game

##


theGame = game.create(startScreen = splash.create())
#theGame.SetScreen(MyScreen())

theGame.Run()
