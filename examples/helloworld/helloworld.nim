# Hello World example
import csfml as sfml
import opengl as gl
import math

import screen
import game
import texture
import font
import music
import sound

type
  HelloWorldScreen* = ref object of Screen
    font: Font
    music: Music
    soundPlayer: SoundPlayer
    someSound: Sound
    time: float32
    text1Alpha, mulX, mulY: int
    txt: Texture
    txtX, txtY: float32

proc createHelloWorldScreen*(): HelloWorldScreen =
  result = HelloWorldScreen()
  result.mulX = 3
  result.mulY = 5

method Init*(screen: HelloWorldScreen) =
  screen.time = 0

  screen.font = createFont("data/fonts/kenvector_future.ttf", color(255,100,0))
  screen.text1Alpha = 0

  screen.music =  createMusic("data/music/DST-TacticalSpace.ogg")
  screen.music.play()

  screen.txt = createTexture("data/images/ufoRed.png")

  screen.soundPlayer = createSoundPlayer()
  screen.someSound = createSound("data/sound/Powerup16.ogg")

method Dispose*(screen: HelloWorldScreen) =
  screen.music.Dispose()
  screen.font.Dispose()
  screen.txt.Dispose()
  screen.someSound.Dispose()
  screen.soundPlayer.Dispose()

method Update*(screen: HelloWorldScreen, delta: float32) =
  screen.time += delta

  screen.text1Alpha = max(int(sin(screen.time * 3) * 255), 0)

  screen.txtX = sin(screen.time * float(screen.mulX)) * 200
  screen.txtY = cos(screen.time * float(screen.mulY)) * 200

method Render*(screen: HelloWorldScreen) =
  screen.txt.draw(screen.txtX, screen.txtY, 50, 50)
  screen.txt.draw(-screen.txtX, screen.txtY, 50, 50)
  screen.txt.draw(screen.txtX, -screen.txtY, 50, 50)
  screen.txt.draw(-screen.txtX, -screen.txtY, 50, 50)
  # actual draw call!
  screen.txt.flush()

  screen.font.SetColor(color(255, 100, 0, 255-screen.text1Alpha))
  screen.font.DrawCentered("Hello  World!", 32, 0'f32, 0'f32)
  screen.font.SetColor(color(0, 100, 255, screen.text1Alpha))
  screen.font.DrawCentered("Try cursor keys...", 24, 0'f32, -100'f32)
  screen.font.SetColor(color(255, 255, 255, 255))
  screen.font.DrawCentered("ESC to quit.", 24, 0'f32, -300'f32)

  screen.font.SetColor(color(255, 200, 0, 100))
  screen.font.DrawLeft("X multiplier: " & $screen.mulX, 16, -250'f32, 400'f32)
  screen.font.DrawRight("Y multiplier: " & $screen.mulY, 16, 250'f32, 400'f32)

method KeyUp*(screen: HelloWorldScreen, key: TKeyCode) =
  if key == sfml.KeyLeft and screen.mulX > 1:
    dec(screen.mulX)
  if key == sfml.KeyRight:
    inc(screen.mulX)
  if key == sfml.KeyDown and screen.mulY > 1:
    dec(screen.mulY)
  if key == sfml.KeyUp:
    inc(screen.mulY)
  if key == sfml.KeySpace:
    screen.soundPlayer.Play(screen.someSound)

### Create the game
var shooter = game.create(startScreen = createHelloWorldScreen(),
                          title = "Hello World!",
                          vsync = false,
                          fullscreen = false,
                          width = 600,
                          height = 900)

shooter.SetClearColor(0.16'f32, 0.16'f32, 0.16'f32)
shooter.SetOrthoHeight(900'f32)
shooter.Run()
