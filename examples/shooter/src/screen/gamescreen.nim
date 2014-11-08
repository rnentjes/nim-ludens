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
  Explosion = ref object of Sprite
    frameTime, currentTime: float32
    frame: int

  GameScreen* = ref object of Screen
    previous: Screen
    font: Font
    music: Music
    sound: Sound
    text1Alpha: int
    time: float32
    player, bullet, ufo, bomb, background, explosion: Texture
    playerX, backgroundY: float32
    bullets: array[0..100, Sprite]
    enemybullets: array[0..100, Sprite]
    explosions: array[0..100, Explosion]
    ufos: array[0..32, Ufo]
    nextBullet, nextEnemyBullet, nextUfo, nextExplosion: int
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

  screen.font = createFont("data/fonts/kenvector_future.ttf", color(255,100,0))

  screen.player = createTexture("data/images/PNG/playerShip1_blue.png")
  screen.bullet = createTexture("data/images/PNG/Lasers/laserBlue01.png")
  screen.ufo = createTexture("data/images/PNG/Enemies/enemyBlack1.png")
  screen.bomb = createTexture("data/images/PNG/Lasers/laserRed10.png")
  screen.background = createTexture("data/images/Backgrounds/darkPurple.png")
  screen.explosion = createTexture("data/images/explosion.png", 5, 5, 25, 0.016'f32)
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
  
proc collides(x1,y1,w1,h1,x2,y2,w2,h2: float32): bool =
  result =  (x1 > x2 and x1 < x2 + w2 and y1 > y2 and y1 < y2 + h2) or
            (x1 + w1 > x2 and x1 + w1 < x2 + w2 and y1 > y2 and y1 < y2 + h2) or
            (x1 > x2 and x1 < x2 + w2 and y1 + h1 > y2 and y1 + h1 < y2 + h2) or
            (x1 + w1 > x2 and x1 + w1 < x2 + w2 and y1 + h1 > y2 and y1 + h1 < y2 + h2)


proc createExplosion(x,y: float32): Explosion =
  result = Explosion()
  result.X(x)
  result.Y(y)
  result.frame = 0
  result.frameTime = 0.016'f32


proc addExplosion(screen: GameScreen, x,y: float32) =
  if screen.nextExplosion < high(screen.explosions):
    screen.explosions[screen.nextExplosion] = createExplosion(x, y)
    screen.nextExplosion += 1


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

    if collides(bomb.x - 10, bomb.y - 10, 20, 20, screen.playerX - 20, -400, 40, 40):
       screen.playerDeath = screen.time
       bomb.Died()

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
         collides(bullet.x - 5, bullet.y - 15, 10, 30, ufo.x - 25, ufo.y, 50, 40): 

        bullet.Died()
        ufo.Died()
        screen.score += 90 + 10 * screen.waveNumber
        screen.addExplosion(ufo.x - 25, ufo.y - 25)

    if not ufo.Dead():
      aliveUfos = true

    if not ufo.Dead() and
      not screen.ufos[i].Dead() and random(1'f32) < screen.bulletsPerSecond * delta and screen.wave.Time() > 4'f32:
      screen.createBomb(screen.ufos[i])

  if not aliveUfos and screen.nextBullet == 0:
    screen.NextWave()

  # cleanup dead bullets
  for i in countup(0, screen.nextExplosion-1):
    var explosion = screen.explosions[i]
    
    explosion.currentTime += delta

    if explosion.currentTime > explosion.frameTime:
      explosion.frame += 1
      explosion.currentTime -= explosion.frameTime

    if explosion.frame > 24:
      screen.explosions[i] = screen.explosions[screen.nextExplosion - 1]
      screen.nextExplosion -= 1


  if sfml.isKeyPressed(KeyLeft):
    screen.playerX -= 250 * delta

  if sfml.isKeyPressed(KeyRight):
    screen.playerX += 250 * delta

  screen.playerX = max(screen.playerX, -250)
  screen.playerX = min(screen.playerX, 250)

  screen.backgroundY += backgroundSpeed * delta
  screen.backgroundY = screen.backgroundY mod 256

  if screen.playerDeath > 0 and screen.time - screen.playerDeath > 5'f32:
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

  if screen.playerDeath == 0:
    screen.player.draw(screen.playerX - 25, -400, 50, 50)

  for i in countup(0, screen.nextExplosion-1):
    var explosion = screen.explosions[i]

    screen.explosion.draw(explosion.x - 25, explosion.y - 25, 100, 100, explosion.frame)

  # actual draw calls
  screen.background.flush()
  screen.bullet.flush() 
  screen.bomb.flush()
  screen.ufo.flush()
  screen.player.flush()
  screen.explosion.flush()

  if screen.playerDeath > 0:
    var alpha = int((screen.time - screen.playerDeath) * 255)
    alpha = min(alpha, 255)
    screen.font.SetColor(color(255, 200, 0, alpha))
    screen.font.DrawCentered("Game Over!", 48, 0'f32, 0'f32)

  if screen.text1Alpha > 0:
    screen.font.SetColor(color(255, 100, 0, screen.text1Alpha))
    screen.font.DrawCentered("Shoot All Enemies!", 32, 0'f32, 0'f32)

  if screen.time - screen.waveStart < 2:
    var alpha = 512 - (256 * (screen.time - screen.waveStart))
    alpha = min(alpha, 255)
    alpha = max(alpha, 0)
    screen.font.SetColor(color(255, 50, 0, int(alpha)))
    screen.font.DrawCentered("Wave " & intToStr(screen.waveNumber), 48, 0'f32, -200'f32)


  screen.font.SetColor(color(255, 200, 10, 150))
  screen.font.DrawLeft("Score: " & intToStr(screen.score), 24, -280'f32, -420'f32)
  screen.font.DrawRight("Wave: " & intToStr(screen.waveNumber), 24, 280'f32, -420'f32)

method KeyUp*(screen: GameScreen, key: TKeyCode) =
  if key == sfml.KeySpace:
    screen.fired = false


method KeyDown*(screen: GameScreen, key: TKeyCode) =
  if key == sfml.KeySpace and screen.nextBullet < high(screen.bullets) and not screen.fired and screen.playerDeath == 0:
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
