import csfml as sfml
import math
import opengl as gl

import screen
import texture
import game
import music

import gamescreen

#

type
  SplashScreen* = ref object of Screen
    font: PFont
    text1: PText
    music: Music
    text1Width, text1Height, time: float32
    text1Alpha: int

##

proc create*(): SplashScreen =
  result = SplashScreen()


method Init*(screen: SplashScreen) =
  screen.time = 0

  screen.font = newFont("fonts/COMPUTERRobot.ttf")
  screen.text1 = newText("Press Space to Start!", screen.font, 64)
  screen.text1Width = screen.text1.getGlobalBounds().width
  screen.text1Height = screen.text1.getGlobalBounds().height
  screen.text1.setPosition(vec2f(-screen.text1Width / 2, -screen.text1Height / 2))
  screen.text1Alpha = 0




method Update*(screen: SplashScreen, delta: float32) =
  screen.time += delta

  screen.text1Alpha = max(int(sin(screen.time * 3) * 255), 0)


method Render*(screen: SplashScreen) =
  screen.text1.setColor(color(255, 100, 0, screen.text1Alpha))
  screen.DrawText(screen.text1)




method KeyUp*(screen: SplashScreen, key: TKeyCode) =
  if key == sfml.KeySpace:
    ludens.SetScreen(createGameScreen())
