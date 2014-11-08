import csfml as sfml
import math
import strutils

import game
import screen
import texture
import music
import sound
import font
import sprite

import objects/ufo

#

const
  backgroundSpeed = -50'f32

type
  GameScreen* = ref object of Screen
    previous: Screen
    font: Font
    music: Music
    sound: Sound
    text1Alpha: int
    time: float32
    player, bullet, ufo, bomb, background: Texture
    playerX, backgroundY: float32
    bullets: array[0..100, Sprite]
    enemybullets: array[0..100, Sprite]
    ufos: array[0..32, Ufo]
    nextBullet, nextEnemyBullet, nextUfo: int
    wave: Wave
    waveNumber, score: int
    waveStart: float32
    bulletsPerSecond: float32
    fired: bool
    playerDeath: float32


##

proc NextWave(screen: GameScreen)

##

proc createGameScreen*(previous: Screen): GameScreen =
  result = GameScreen(playerX: 0)
  result.previous = previous


method Init*(screen: GameScreen) = 
  screen.time = -1

  screen.font = createFont("data/fonts/COMPUTERRobot.ttf", color(255,100,0))

  screen.player = createTexture("data/images/PNG/playerShip1_blue.png")
  screen.bullet = createTexture("data/images/PNG/Lasers/laserBlue01.png")
  screen.ufo = createTexture("data/images/PNG/Enemies/enemyBlack1.png")
  screen.bomb = createTexture("data/images/PNG/Lasers/laserRed10.png")
  screen.background = createTexture("data/images/Backgrounds/darkPurple.png")
  screen.playerX = 0
  screen.playerDeath = 0

  screen.waveNumber = 1
  screen.score = 0
  screen.waveStart = 0
  screen.bulletsPerSecond = 0.01'f32

  screen.nextBullet = 0
  screen.nextEnemyBullet = 0
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


proc createBomb(screen: GameScreen, ufo: Ufo) =
  if screen.nextEnemyBullet < high(screen.enemybullets):
    # new bomb
    screen.enemybullets[screen.nextEnemyBullet] = createSprite(ufo.X(), ufo.Y(), 0, -300)
    screen.nextEnemyBullet += 1
    screen.sound.Play("data/sound/Powerup16.ogg")
  

method Update*(screen: GameScreen, delta: float32) =
  if screen.time < 0:
    screen.time = 0
    screen.waveStart = 0
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

  # move bombs
  for i in countup(0, screen.nextEnemyBullet-1):
    var bomb = screen.enemybullets[i]

    bomb.Update(delta)

    if bomb.x - 10 < screen.playerX + 25 and
       bomb.y - 10 < -400 and
       bomb.x + 10 > screen.playerX - 25 and
       bomb.y + 10 > -350:
       screen.playerDeath = screen.time

    if bomb.y < -450:
      bomb.Died()

  # cleanup dead bombs
  for i in countup(0, screen.nextEnemyBullet-1):
    var bomb = screen.enemybullets[i]

    if bomb.Dead():
      screen.enemybullets[i] = screen.enemybullets[screen.nextEnemyBullet - 1]
      screen.nextEnemyBullet -= 1

  screen.wave.Update(delta)

  # Update ufos
  var aliveUfos = false
  for i in countup(0, 31):
    var ufo = screen.ufos[i] 
    ufo.Update(delta)

    for i in countup(0, screen.nextBullet-1):
      var bullet = screen.bullets[i]

      if not ufo.Dead() and
         bullet.x - 5 < ufo.x + 25 and 
         bullet.y < ufo.y + 40 and
         bullet.x + 5 > ufo.x - 25 and
         bullet.y + 30 > ufo.y: 
        bullet.Died()
        ufo.Died()
        screen.score += 90 + 10 * screen.waveNumber

    if not ufo.Dead():
      aliveUfos = true

    if not ufo.Dead() and
      not screen.ufos[i].Dead() and random(1'f32) < screen.bulletsPerSecond * delta and screen.wave.Time() > 4'f32:
      screen.createBomb(screen.ufos[i])

  if not aliveUfos and screen.nextBullet == 0:
    screen.NextWave()

  if sfml.isKeyPressed(KeyLeft):
    screen.playerX -= 250 * delta

  if sfml.isKeyPressed(KeyRight):
    screen.playerX += 250 * delta

  screen.playerX = max(screen.playerX, -250)
  screen.playerX = min(screen.playerX, 250)

  screen.backgroundY += backgroundSpeed * delta
  screen.backgroundY = screen.backgroundY mod 256

  if screen.time - screen.playerDeath > 5'f32:
    ludens.SetScreen(screen.previous)


method Render*(screen: GameScreen) =
  var y = screen.backgroundY - ( 450 + 256 )
  for i in countup(0, 4):
    screen.background.draw(0, y, 256, 256)
    screen.background.draw(256, y, 256, 256)
    screen.background.draw(-256, y, 256, 256)
    screen.background.draw(-512, y, 256, 256)
    y = y + 256

  for i in countup(0, screen.nextBullet-1):
    var bullet = screen.bullets[i]
    screen.bullet.draw(bullet.X() - 5, bullet.Y(), 10, 30)

  for i in countup(0, screen.nextEnemyBullet-1):
    var bomb = screen.enemybullets[i]
    screen.bomb.draw(bomb.X() - 5, bomb.Y(), 20, 20)

  for i in countup(0, 31):
    var ufo = screen.ufos[i]
    if not ufo.Dead():
      screen.ufo.draw(ufo.X() - 25, ufo.Y(), 50, 40)

  screen.player.draw(screen.playerX - 25,-400, 50, 50)

  # actual draw calls
  screen.background.flush()
  screen.bullet.flush()
  screen.bomb.flush()
  screen.ufo.flush()
  screen.player.flush()

  if screen.text1Alpha > 0:
    screen.font.SetColor(color(255, 100, 0, screen.text1Alpha))
    screen.font.DrawCentered("Shoot All Enemies!", 64, 0'f32, 0'f32)

  if screen.time - screen.waveStart < 2:
    var alpha = 512 - (256 * (screen.time - screen.waveStart))
    alpha = min(alpha, 255)
    alpha = max(alpha, 0)
    screen.font.SetColor(color(255, 50, 0, int(alpha)))
    screen.font.DrawCentered("Wave " & intToStr(screen.waveNumber), 96, 0'f32, -200'f32)


  screen.font.SetColor(color(255, 200, 10, 150))
  screen.font.DrawLeft("Score: " & intToStr(screen.score), 24, -280'f32, -420'f32)
  screen.font.DrawRight("Wave: " & intToStr(screen.waveNumber), 24, 280'f32, -420'f32)

method KeyUp*(screen: GameScreen, key: TKeyCode) =
  if key == sfml.KeySpace:
    screen.fired = false


method KeyDown*(screen: GameScreen, key: TKeyCode) =
  if key == sfml.KeySpace and screen.nextBullet < high(screen.bullets) and not screen.fired:
    # new bullet
    screen.bullets[screen.nextBullet] = createSprite(screen.playerX, -360, 0, 750)
    screen.nextBullet += 1
    screen.sound.Play("data/sound/Powerup16.ogg")
    screen.fired = true

  if key == sfml.KeyW:
    screen.NextWave()


proc NextWave(screen: GameScreen) =
    inc(screen.waveNumber)
    screen.bulletsPerSecond += 0.01'f32
    screen.waveStart = screen.time
    screen.wave = createSimpleWave()

    for i in countup(0, 31):
      screen.ufos[i] = createUfo(screen.wave, i)
