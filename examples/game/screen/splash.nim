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

  SplashScreen2* = ref object of Screen

##

proc create2*(): SplashScreen2

proc create*(): SplashScreen =
  result = SplashScreen()


method Init*(screen: SplashScreen) =
  echo "set clear color"
  gl.glClearColor(0.2,0.0,0.2,1.0)

  screen.txt = createRawTexture("assets/images/playerhappy128_128.rgba", 128, 128)
  screen.txt2 = createTexture("assets/images/yellow_star.png")


method Update*(screen: SplashScreen, delta: float32) =
  screen.time += delta

  screen.x = sin(screen.time)
  screen.y = cos(screen.time)


method Render*(screen: SplashScreen) =
  gl.glClear(GL_COLOR_BUFFER_BIT)

  screen.txt.draw(screen.x,screen.y,1,1)
  screen.txt.draw(screen.x-1,screen.y,1,1)
  screen.txt2.draw(screen.x,screen.y-1,0.4,0.4)
  screen.txt.draw(-1,-1,0.5,0.5)
  screen.txt.draw(0,2,1,1)
  screen.txt.draw(-3,0,1,1)

  screen.txt2.flush()    # actual draw call
  screen.txt.flush()    # actual draw call


method KeyUp*(screen: SplashScreen, key, scancode, mods: int) =
  globalGame.SetScreen(create2())

##############################################3

proc create2*(): SplashScreen2 =
  result = SplashScreen2()


method Init*(screen: SplashScreen2) =
  gl.glClearColor(0.2,1.0,0.2,1.0)


method Update*(screen: SplashScreen2, delta: float32) =
  discard


method Render*(screen: SplashScreen2) =
  gl.glClear(GL_COLOR_BUFFER_BIT)


method KeyUp*(screen: SplashScreen2, key, scancode, mods: int) =
  globalGame.SetScreen(create())


