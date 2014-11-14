import csfml as sfml
import math

import screen
import texture
import game
import music
import font

import gamescreen

#

type
  SplashScreen* = ref object of Screen
    font: Font
    music: Music
    time: float32
    text1Alpha: int

var
  texts1 = ["Music", "Graphics", "Programming"]

  texts2 = ["DeceasedSuperiorTechnician", "Kenney.nl", "Rien Nentjes"]
  currentText = 0
  textTime = 0'f32

##

proc createSplash*(): SplashScreen =
  result = SplashScreen()


method Init*(screen: SplashScreen) =
  screen.time = 0

  screen.font = createFont("data/fonts/kenvector_future.ttf", color(255,100,0))
  screen.text1Alpha = 0

  screen.music =  createMusic("data/music/DST-TacticalSpace.ogg")
  screen.music.play()


method Dispose*(screen: SplashScreen) =
  screen.music.Dispose()
  screen.font.Dispose()


method Update*(screen: SplashScreen, delta: float32) =
  screen.time += delta
  textTime += delta

  if textTime > 8:
    textTime = 0
    currentText += 1
    currentText = currentText mod len(texts1)

  screen.text1Alpha = max(int(sin(screen.time * 3) * 255), 0)


method Render*(screen: SplashScreen) =
  screen.font.SetColor(color(255, 100, 0, screen.text1Alpha))
  screen.font.DrawCentered("Press Space to Start!", 32, 0'f32, 0'f32)

  var textAlpha = 255;
  if textTime < 3:
    textAlpha = int((textTime - 2) * 255)
    textAlpha = max(textAlpha, 0)
  elif textTime > 7:
    textAlpha = int((8-textTime) * 255)

  screen.font.SetColor(color(0, 150, 255, textAlpha))
  screen.font.DrawCentered(texts1[currentText], 24, 0'f32, -200'f32)
  screen.font.DrawCentered(texts2[currentText], 24, 0'f32, -240'f32)





method KeyUp*(screen: SplashScreen, key: TKeyCode) =
  if key == sfml.KeySpace:
    ludens.SetScreen(createGameScreen(screen))
