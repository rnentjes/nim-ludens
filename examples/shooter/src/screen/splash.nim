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

  screen.text1Alpha = max(int(sin(screen.time * 3) * 255), 0)


method Render*(screen: SplashScreen) =
  screen.font.SetColor(color(255, 100, 0, screen.text1Alpha))
  screen.font.DrawCentered("Press Space to Start!", 32, 0'f32, 0'f32)



method KeyUp*(screen: SplashScreen, key: TKeyCode) =
  if key == sfml.KeySpace:
    ludens.SetScreen(createGameScreen(screen))
