import screen
import opengl as gl

import texture

#

type
  SplashScreen* = ref object of Screen
    txt: Texture

##

proc create*(): SplashScreen =
  result = SplashScreen()


method Init*(screen: SplashScreen) =
    echo "set clear color"
    gl.glClearColor(0.2,0.0,0.2,1.0)

    screen.txt = createRawTexture("assets/images/playerhappy128_128.rgba", 128, 128)

method Render*(screen: SplashScreen, delta: float32) =
    gl.glClear(GL_COLOR_BUFFER_BIT)

    screen.txt.draw(0,0,1,1)

