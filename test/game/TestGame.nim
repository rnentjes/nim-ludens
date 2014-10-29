import screen
import game
import opengl as gl

#

type
  MyScreen* = ref object of Screen

#

var
  theGame: Game

#

method Init*(screen: MyScreen, delta: float32) =
    gl.glClearColor(0.2,0.0,0.2,1.0)

method Render*(screen: MyScreen, delta: float32) =
    gl.glClear(GL_COLOR_BUFFER_BIT)

##

theGame = Game(gameScreen: MyScreen())
#theGame.SetScreen(MyScreen())
theGame.Run()
