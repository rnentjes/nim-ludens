import screen
import game
import opengl as gl

import "screen/splash"

#

#var
#  theGame: Game

##

var theGame = game.create(startScreen = splash.create())
#theGame.SetScreen(MyScreen())
theGame.Run()
