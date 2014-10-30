import screen
import opengl as gl

#

type
  SplashScreen* = ref object of Screen

##

proc create*(): SplashScreen =
  result = SplashScreen()

method Init*(screen: SplashScreen) =
    echo "set clear color"
    gl.glClearColor(0.2,0.0,0.2,1.0)

method Render*(screen: SplashScreen, delta: float32) =
    gl.glClear(GL_COLOR_BUFFER_BIT)

