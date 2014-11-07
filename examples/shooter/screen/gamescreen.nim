import csfml as sfml
import math
import opengl as gl
import strutils

import screen
import texture
import game
import music
import font

#

type
  Sprite = ref object
    x,y,dx,dy: float32
    dead: bool

  GameScreen* = ref object of Screen
    font: Font
    music: Music
    text1Alpha: int
    time: float32
    player, bullet, ufo: Texture
    playerX: float32
    bullets: array[0..100, Sprite]
    ufos: array[0..100, Sprite]
    nextBullet, nextUfo: int

##

proc createGameScreen*(): GameScreen =
  result = GameScreen(playerX: 0)


method Init*(screen: GameScreen) =
  screen.time = -1

  screen.font = createFont("fonts/COMPUTERRobot.ttf", color(255,100,0))

  screen.player = createTexture("images/PNG/playerShip1_blue.png")
  screen.bullet = createTexture("images/PNG/Lasers/laserBlue01.png")
  screen.playerX = 0

  screen.nextBullet = 0
  screen.nextUfo = 0

  screen.music =  createMusic("music/DST-TechnoBasic.ogg")
  screen.music.play()

  randomize()


method Dispose*(screen: GameScreen) =
  screen.music.Dispose()


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

    bullet.x += bullet.dx * delta
    bullet.y += bullet.dy * delta

    if bullet.y > 450:
      bullet.dead = true

  # cleanup dead bullets
  for i in countup(0, screen.nextBullet-1):
    var bullet = screen.bullets[i]

    if bullet.dead:
      screen.bullets[i] = screen.bullets[screen.nextBullet - 1]
      screen.nextBullet -= 1


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
  screen.font.DrawCentered("Bullets: " & intToStr(screen.nextBullet), 24, -240'f32, -420'f32)

  screen.player.draw(screen.playerX - 25,-400, 50, 50)

  for i in countup(0, screen.nextBullet-1):
    var bullet = screen.bullets[i]
    screen.bullet.draw(bullet.x - 5, bullet.y, 10, 30)

  screen.player.flush()
  screen.bullet.flush()


method KeyDown*(screen: GameScreen, key: TKeyCode) =
  if key == sfml.KeySpace and screen.nextBullet < 50:
    # new bullet
    screen.bullets[screen.nextBullet] = Sprite(x: screen.playerX, y: -360, dx: 0, dy: 750)
    screen.nextBullet += 1

