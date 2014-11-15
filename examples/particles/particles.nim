import csfml as sfml
import csfml
import opengl as gl
import math
import strutils

import screen
import game
import texture
import font
import music

import particle
#

type
  Part* = ref object
    x,y,dx,dy,a,da: float32

  ExampleScreen* = ref object of Screen
    font: Font
    time: float32
    number: int
    pmesh: ParticleMesh
    particles: seq[Part]

##

proc createScreen*(): ExampleScreen =
  result = ExampleScreen()
  result.number = 5000
  result.particles = newSeq[Part]()


method newParticle(screen: ExampleScreen) =
  var p = Part()
  p.x = random(10'f32) - 5
  p.y = -100 + random(10'f32)
  p.a = 0.3

  var angle = random(1'f32) + 1.12'f32
  var length = random(300'f32) + 100'f32
  p.dx = cos(angle) * length
  p.dy = sin(angle) * length
  p.da = -0.3'f32 - random(0.2'f32)

  screen.particles.add(p)


method Init*(screen: ExampleScreen) =
  screen.time = 0

  screen.font = createFont("data/fonts/COMPUTERRobot.ttf", color(255,100,0))

  screen.pmesh = createParticleMesh()

  randomize()

  for i in countup(1, 100):
    screen.newParticle()


method Dispose*(screen: ExampleScreen) =
  screen.pmesh.Dispose()
  screen.font.Dispose()


method Update*(screen: ExampleScreen, delta: float32) =
  screen.time += delta;

  for i, p in screen.particles:
    p.x += p.dx * delta
    p.y += p.dy * delta
    p.a += p.da * delta

    # gravity
    p.dy -= 300 * delta

    if p.a < 0:
      screen.particles[i] = screen.particles[len(screen.particles)-1]
      discard screen.particles.pop()

  if len(screen.particles) < screen.number:
    var toCreate = screen.number - len(screen.particles)
    toCreate = int(float32(toCreate) * delta)
    toCreate = max(toCreate, 1)
    for i in countup(1, toCreate):
      screen.newParticle()


method Render*(screen: ExampleScreen) =

  for i, p in screen.particles:
    screen.pmesh.draw(p.x, p.y, -1, 10, 1, 0.05'f32, 0.05'f32, p.a)

  # actual draw call!
  screen.pmesh.flush()

  screen.font.SetColor(color(255, 255, 255, 255))
  screen.font.DrawCentered("Particles: " & $len(screen.particles), 32, 0'f32, -200'f32)

  screen.font.SetColor(color(0, 100, 255, 225))
  screen.font.DrawCentered("Try cursor keys...", 24, 0'f32, -250'f32)

  screen.font.SetColor(color(0, 0, 0, 225))
  screen.font.DrawCentered("FrameRate: " & formatFloat(ludens.GetFrameRate(), ffDefault, 4), 24, 0'f32, -300'f32)
  screen.font.DrawCentered("FrameTime: " & formatFloat(ludens.GetFrameTime(), ffDefault, 4), 24, 0'f32, -325'f32)


method KeyUp*(screen: ExampleScreen, key: TKeyCode) =
  var multiplier = 1.1
  if key == sfml.KeyLeft:
    screen.number = int(float(screen.number) / multiplier)

  if key == sfml.KeyRight:
    screen.number = int(float(screen.number) * multiplier)

  if key == sfml.KeyDown:
    screen.number = int(float(screen.number) / multiplier)

  if key == sfml.KeyUp:
    screen.number = int(float(screen.number) * multiplier)

  screen.number = max(screen.number, 5)


### Create the game

var particles = game.create(startScreen = createScreen(),
                          title = "Particles Test",
                          vsync = false,
                          fullscreen = false,
                          width = 600,
                          height = 900)

particles.SetClearColor(0.16'f32, 0.16'f32, 0.16'f32)
particles.SetOrthoHeight(900'f32)
particles.Run()
