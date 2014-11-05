import src/glfw3 as glfw
import math
import opengl as gl

import screen
import texture
import game

#

type
  SplashScreen* = ref object of Screen
    txt, txt2: Texture
    time: float32
    x,y: float32

##

proc create*(): SplashScreen =
  result = SplashScreen()


method Init*(screen: SplashScreen) =
  echo "set clear color"
  gl.glClearColor(0.2,0.0,0.2,1.0)


method Update*(screen: SplashScreen, delta: float32) =
  screen.time += delta

  screen.x = sin(screen.time)
  screen.y = cos(screen.time)


method Render*(screen: SplashScreen) =
  gl.glClear(GL_COLOR_BUFFER_BIT)

