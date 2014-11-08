import csfml as sfml
import math
import opengl as gl
import strutils

import screen
import texture
import game
import music
import sound
import font
import sprite
import objects/ufo

#

type
  GameScreen* = ref object of Screen
    font: Font
    music: Music
    sound: Sound
    text1Alpha: int
    time: float32
    player, bullet, ufo: Texture
    playerX: float32
    bullets: array[0..100, Sprite]
    ufos: array[0..32, Ufo]
    nextBullet, nextUfo: int
    wave: Wave

##

proc createGameScreen*(): GameScreen =
  result = GameScreen(playerX: 0)


method Init*(screen: GameScreen) =
  screen.time = -1

  screen.font = createFont("data/fonts/COMPUTERRobot.ttf", color(255,100,0))

  screen.player = createTexture("data/images/PNG/playerShip1_blue.png")
  screen.bullet = createTexture("data/images/PNG/Lasers/laserBlue01.png")
  screen.ufo = createTexture("data/images/PNG/Enemies/enemyBlack1.png")
  screen.playerX = 0

  screen.nextBullet = 0
  screen.nextUfo = 0

  screen.music =  createMusic("data/music/DST-TechnoBasic.ogg")
  screen.music.play()

  screen.sound = createSound()
  # pre load sound
  screen.sound.Load("data/sound/Powerup16.ogg")

  screen.wave = createSimpleWave()

  for i in countup(0, 31):
    screen.ufos[i] = createUfo(screen.wave, i)

  randomize()


method Dispose*(screen: GameScreen) =
  screen.music.Dispose()
  screen.sound.Dispose()


method Update*(screen: GameScreen, delta: float32) =
  if screen.time < 0:
    screen.time = 0
  else:
    screen.time += delta

  if screen.time < PI * 6 / 8:
    screen.text1Alpha = max(int(sin(screen.time * 8) * 255), 0)
  else:
    screen.text1Alpha = 0

  # move bullets
  for i in countup(0, screen.nextBullet-1):
    var bullet = screen.bullets[i]

    bullet.Update(delta)

    if bullet.y > 450:
      bullet.Died()

  # cleanup dead bullets
  for i in countup(0, screen.nextBullet-1):
    var bullet = screen.bullets[i]

    if bullet.Dead():
      screen.bullets[i] = screen.bullets[screen.nextBullet - 1]
      screen.nextBullet -= 1

  screen.wave.Update(delta)

  # Update ufos
  for i in countup(0, 31):
    screen.ufos[i].Update(delta)

  if sfml.isKeyPressed(KeyLeft):
    screen.playerX -= 250 * delta

  if sfml.isKeyPressed(KeyRight):
    screen.playerX += 250 * delta

  screen.playerX = max(screen.playerX, -250)
  screen.playerX = min(screen.playerX, 250)


method Render*(screen: GameScreen) =
  if screen.text1Alpha > 0:
    screen.font.SetColor(color(255, 100, 0, screen.text1Alpha))
    screen.font.DrawCentered("Shoot All Enemies!", 64, 0'f32, 0'f32)

  screen.font.SetColor(color(255, 200, 10, 150))
  screen.font.DrawLeft("Bullets: " & intToStr(screen.nextBullet), 24, -280'f32, -420'f32)

  screen.player.draw(screen.playerX - 25,-400, 50, 50)

  for i in countup(0, screen.nextBullet-1):
    var bullet = screen.bullets[i]
    screen.bullet.draw(bullet.X() - 5, bullet.Y(), 10, 30)

  for i in countup(0, 31):
    var ufo = screen.ufos[i]
    screen.ufo.draw(ufo.X() - 25, ufo.Y(), 50, 40)

  screen.player.flush()
  screen.bullet.flush()
  screen.ufo.flush()


method KeyDown*(screen: GameScreen, key: TKeyCode) =
  if key == sfml.KeySpace and screen.nextBullet < high(screen.bullets):
    # new bullet
    screen.bullets[screen.nextBullet] = createSprite(screen.playerX, -360, 0, 750)
    screen.nextBullet += 1
    screen.sound.Play("data/sound/Powerup16.ogg")

