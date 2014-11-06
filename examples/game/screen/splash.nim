import math
import opengl as gl
import strutils
import csfml as sfml
import csfml_audio as audio

import screen
import texture
import game
import sound
import music

#

type
  SplashScreen* = ref object of Screen
    txt, txt2: Texture
    time: float32
    x,y: float32
    font: PFont
    text1: PText
    sound: Sound
    music: Music

  SplashScreen2* = ref object of Screen
    font: PFont
    text1: PText
    music: Music

##

proc create2*(): SplashScreen2

proc create*(): SplashScreen =
  result = SplashScreen()


method Init*(screen: SplashScreen) =
  screen.txt = createTexture("assets/images/playerunhappy.png")
  screen.txt2 = createTexture("assets/images/yellow_star.png")
  screen.font = newFont("assets/fonts/SHOWG.TTF")
  screen.text1 = newText("Hello World!", screen.font, 48)
  screen.text1.setPosition(vec2f(200, 100))
  screen.text1.setColor(color(200, 100, 50))

  echo "text w,h " & $screen.text1.getLocalBounds().width & " " & $screen.text1.getLocalBounds().height

  screen.sound = createSound()
  screen.sound.Load("assets/snd/Powerup16.ogg")

  screen.music = createMusic("assets/music/DST-DFree.ogg")
  screen.music.play()


method Dispose*(screen: SplashScreen) =
  screen.music.Dispose()
  screen.sound.Dispose()


method Update*(screen: SplashScreen, delta: float32) =
  screen.time += delta

  screen.x = sin(screen.time) * 100
  screen.y = cos(screen.time) * 100


method Render*(screen: SplashScreen) =

  screen.txt.draw(screen.x,screen.y,50,50)
  screen.txt.draw(screen.x-70,screen.y,50,50)
  screen.txt2.draw(screen.x,screen.y-60, 25, 25)
  screen.txt.draw(-50, -50, 25, 25)

  screen.txt2.flush()    # actual draw call
  screen.txt.flush()    # actual draw call

  screen.text1.setPosition(vec2f(0, 0))
  screen.text1.setColor(color(200, 100, 50))
  screen.DrawText(screen.text1)

  screen.text1.setPosition(vec2f(-2, -2))
  screen.text1.setColor(color(255, 200, 100))
  screen.DrawText(screen.text1)


method KeyUp*(screen: SplashScreen, key: TKeyCode) =
  if key == sfml.KeyP:
    screen.sound.Play("assets/snd/Powerup16.ogg")
  else:
    ludens.SetScreen(create2())

##############################################3

proc create2*(): SplashScreen2 =
  result = SplashScreen2()


method Init*(screen: SplashScreen2) =
  screen.font = newFont("assets/fonts/COMPUTERRobot.ttf")
  screen.text1 = newText("Screen 2!", screen.font, 128)

  screen.music = createMusic("assets/music/DST-AngryRobotIII.ogg")
  screen.music.play()


method Dispose*(screen: SplashScreen2) =
  screen.music.Dispose()

method Update*(screen: SplashScreen2, delta: float32) =
  discard


method Render*(screen: SplashScreen2) =
  screen.text1.setPosition(vec2f(-300, -500))
  screen.text1.setColor(color(255, 100, 00))
  screen.DrawText(screen.text1)


method KeyUp*(screen: SplashScreen2, key: TKeyCode) =
  ludens.SetScreen(create())

