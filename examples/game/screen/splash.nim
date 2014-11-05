import math
import opengl as gl
import strutils
import csfml as sfml
import csfml_audio as audio

import screen
import texture
import game

#

type
  SplashScreen* = ref object of Screen
    txt, txt2: Texture
    time: float32
    x,y: float32
    font: PFont
    text1: PText
    snd: PSoundBuffer

  SplashScreen2* = ref object of Screen
    font: PFont
    text1: PText

##

proc create2*(): SplashScreen2

proc create*(): SplashScreen =
  result = SplashScreen()


method Init*(screen: SplashScreen) =
  echo "set clear color"
  gl.glClearColor(0.2,0.0,0.2,1.0)

  screen.txt = createTexture("assets/images/playerunhappy.png")
  screen.txt2 = createTexture("assets/images/yellow_star.png")
  screen.font = newFont("assets/fonts/SHOWG.TTF")
  screen.text1 = newText("Hello World!", screen.font, 48)

  screen.snd = newSoundBuffer("assets/sounds/Powerup16.mp3")


method Update*(screen: SplashScreen, delta: float32) =
  screen.time += delta

  screen.x = sin(screen.time)
  screen.y = cos(screen.time)


method Render*(screen: SplashScreen) =
  globalGame.Text(screen.text1)

  screen.txt.draw(screen.x,screen.y,1,1)
  screen.txt.draw(screen.x-1,screen.y,1,1)
  screen.txt2.draw(screen.x,screen.y-1,0.4,0.4)
  screen.txt.draw(-1,-1,0.5,0.5)
  screen.txt.draw(0,2,1,1)
  screen.txt.draw(-3,0,1,1)

  screen.txt2.flush()    # actual draw call
  screen.txt.flush()    # actual draw call



method KeyUp*(screen: SplashScreen, key: TKeyCode) =
  if key == sfml.KeyP:
    var sound = newSound()
    sound.setBuffer(screen.snd)
    sound.play()
  else:
    globalGame.SetScreen(create2())

##############################################3

proc create2*(): SplashScreen2 =
  result = SplashScreen2()


method Init*(screen: SplashScreen2) =
  screen.font = newFont("assets/fonts/SHOWG.TTF")
  screen.text1 = newText("Hello World!", screen.font, 48)


method Update*(screen: SplashScreen2, delta: float32) =
  discard


method Render*(screen: SplashScreen2) =
  globalGame.Text(screen.text1)


method KeyUp*(screen: SplashScreen2, key: TKeyCode) =
  globalGame.SetScreen(create())


