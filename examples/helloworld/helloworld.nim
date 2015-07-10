## Hello World example
import csfml as sfml
import opengl as gl
import math

import screen
import game
import texture
import font
import music
import sound
import fader

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
    fader: Fader
    fadeAlpha: float32

## constructor for your screen
## note that their might not be an opengl pr sfml context yet,
## so do the loading of images and sound in the Init method
proc createHelloWorldScreen*(): HelloWorldScreen =
  result = HelloWorldScreen()
  result.mulX = 3
  result.mulY = 5
  result.fadeAlpha = 0'f32

## This is called before the screen is first shown
## Do all loading of assets in this method
method Init*(screen: HelloWorldScreen) =
  screen.fader = createFader()

  screen.font = createFont("data/fonts/kenvector_future.ttf", color(255,100,0))
  screen.text1Alpha = 0

  screen.music =  createMusic("data/music/DST-TacticalSpace.ogg")
  screen.music.Play()

  screen.txt = createTexture("data/images/ufoRed.png")

  screen.soundPlayer = createSoundPlayer()
  screen.someSound = createSound("data/sound/Powerup16.ogg")

  screen.time = 0

## Make sure you cleanup your assets here
method Dispose*(screen: HelloWorldScreen) =
  screen.music.Dispose()
  screen.font.Dispose()
  screen.txt.Dispose()
  screen.someSound.Dispose()
  screen.soundPlayer.Dispose()

## Called every frame with the amount of time passed since the last frame
## do your physics updates in here
method Update*(screen: HelloWorldScreen, delta: float32) =
  screen.time += delta

  screen.text1Alpha = max(int(sin(screen.time * 3) * 255), 0)

  screen.txtX = sin(screen.time * float(screen.mulX)) * 400
  screen.txtY = cos(screen.time * float(screen.mulY)) * 400

  if screen.time < 1'f32 and screen.time > 0.8'f32:
    screen.fadeAlpha = 1 - ((1 - screen.time) * 5'f32)

  if screen.time > 1'f32:
    screen.fadeAlpha -= 0.33 * delta

## Called every frame, do your rendering in this method
method Render*(screen: HelloWorldScreen) =
  screen.txt.draw(screen.txtX, screen.txtY)
  screen.txt.draw(-screen.txtX, screen.txtY)
  screen.txt.draw(screen.txtX, -screen.txtY)
  screen.txt.draw(-screen.txtX, -screen.txtY)
  # actual draw call!
  screen.txt.flush()

  screen.font.SetColor(color(255, 100, 0, 255-screen.text1Alpha))
  screen.font.DrawCentered("Hello  World!", 64, 0'f32, 0'f32)
  screen.font.SetColor(color(0, 100, 255, screen.text1Alpha))
  screen.font.DrawCentered("Try cursor keys...", 48, 0'f32, -200'f32)
  screen.font.SetColor(color(255, 255, 255, 255))
  screen.font.DrawCentered("ESC to quit.", 48, 0'f32, -600'f32)

  screen.font.SetColor(color(255, 200, 0, 100))
  screen.font.DrawLeft("X multiplier: " & $screen.mulX, 32, -500'f32, 800'f32)
  screen.font.DrawRight("Y multiplier: " & $screen.mulY, 32, 500'f32, 800'f32)

  if screen.time < 1'f32:
    screen.fader.Fade(0'f32,0'f32,0'f32,1'f32)

  if screen.fadeAlpha > 0:
    screen.fader.Fade(1'f32,1'f32,1'f32,screen.fadeAlpha)
    # screen.fader.Fade(0'f32,0'f32,0'f32,screen.fadeAlpha)

## Called whenever a key is released
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

## Create the game
var helloworld = game.create(startScreen = createHelloWorldScreen(),
                          title = "Hello World!",
                          vsync = true,
                          fullscreen = false,
                          width = 600,
                          height = 900)

## Set the background color
helloworld.SetClearColor(0.16'f32, 0.16'f32, 0.16'f32)

# This sets the height of the screen to 2000 units
# the width will be depending on the aspect ratio
# after resizing, the screen will still be 2000 units high
# this makes it easy to make resolution independent games,
# but the font's and images will be scaled to units as if they are pixels
# so don't make this value to small, or do and get pixelart
helloworld.SetOrthoHeight(2000'f32)

## Start and run the game
helloworld.Run()
