import csfml as sfml
import math
import opengl as gl
import strutils

import screen
import texture
import game
import music

#

type
  Sprite = ref object
    x,y,dx,dy: float32
    dead: bool

  GameScreen* = ref object of Screen
    font: PFont
    text1: PText
    text2: PText
    music: Music
    text1Width, text1Height, time: float32
    text1Alpha: int
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

  screen.font = newFont("fonts/COMPUTERRobot.ttf")
  screen.text1 = newText("Shoot All Enemies!", screen.font, 64)
  screen.text1Width = screen.text1.getGlobalBounds().width
  screen.text1Height = screen.text1.getGlobalBounds().height
  screen.text1.setPosition(vec2f(-screen.text1Width / 2, -screen.text1Height / 2))
  screen.text1Alpha = 0

  screen.text2 = newText("Bullets: 0", screen.font, 24)
  screen.text2.setPosition(vec2f(-280, -420))

  screen.player = createTexture("images/PNG/playerShip1_blue.png")
  screen.bullet = createTexture("images/PNG/Lasers/laserBlue01.png")
  screen.playerX = 0

  screen.nextBullet = 0
  screen.nextUfo = 0


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
    echo "bullet: " & $i
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
  screen.text1.setColor(color(255, 100, 0, screen.text1Alpha))
  screen.DrawText(screen.text1)
  screen.text2.setString("Bullets: " & intToStr(screen.nextBullet))
  screen.DrawText(screen.text2)

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
