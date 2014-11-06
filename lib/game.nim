import csfml as sfml
import opengl as gl
import IL, ILU
import strutils

import screen
import matrix

type
  Projection = enum
    prProjection, prWidth, prHeight
  Game* = ref object of TObject
    gameScreen*: Screen
    running: bool
    startTime: cdouble
    window: sfml.PRenderWindow
    title*: string
    clock: PClock
    lastTime, currentTime, lastFPSTime: float32
    frameCount: int
    projection: Projection
    viewportWidth, viewportHeight: int
    width, height: float32
    projectionmatrix*: PMatrix
    fov, near, far: float32
    clearColor: TColor
    textview: PView


var
  #global
  globalGame*: Game


proc Dispose(game: Game)
proc Initialize(game: Game)
proc Resize(game: Game, width, height: int)
proc SetScreen*(game: Game, gameScreen: Screen)

proc create*(title: string = "Ludens", startScreen: Screen, width: int = 800, height: int = 600): Game =
  if globalGame != nil:
    globalGame.Dispose()

  globalGame = Game()
  globalGame.clock = newClock()
  globalGame.running = false
  globalGame.title = title
  globalGame.gameScreen = startScreen
  globalGame.lastTime = float32(sfml.getElapsedTime(globalGame.clock).microseconds) / 1000000'f32
  globalGame.currentTime = float(sfml.getElapsedTime(globalGame.clock).microseconds) / 1000000'f32
  globalGame.lastFPSTime = 0
  globalGame.frameCount = 0
  globalGame.projection = prProjection
  globalGame.projectionmatrix = createMatrix()
  globalGame.fov = 75'f32
  globalGame.near = 1'f32
  globalGame.far = 25'f32
  globalGame.clearColor = sfml.color(20, 0, 20)
  globalGame.viewportWidth = width
  globalGame.viewportHeight = height

  globalGame.Initialize()
  globalGame.Resize(globalGame.viewportWidth, globalGame.viewportHeight)

  result = globalGame


#proc KeyInput(game: Game, key, scancode, action, mods: cint) {.cdecl.} =
#  echo "key: " & intToStr(key) & ", " & intToStr(scancode) & ", " & intToStr(action)
#
#  if action == PRESS:
#    globalGame.gameScreen.KeyDown(key, scancode, mods)
#  elif action == RELEASE:
#    globalGame.gameScreen.KeyUp(key, scancode, mods)
#  elif action == REPEAT:
#    globalGame.gameScreen.KeyRepeat(key, scancode, mods)

proc Resize(game: Game, width, height: int) =
  game.viewportWidth = width
  game.viewportHeight = height

  game.window.setSize(vec2i(width, height))
  echo("Resize: ", intToStr(width), ", ", intToStr(height))

  var aspect = float32(globalGame.viewportWidth) / float32(globalGame.viewportHeight)
  case game.projection:
    of prProjection:
      game.projectionmatrix.PerspectiveProjection(75.0'f32, aspect, globalGame.near, globalGame.far)
    of prWidth:
      game.height = globalGame.width / aspect
      game.projectionmatrix.OrthographicProjection(-globalGame.width / 2, globalGame.width / 2, -globalGame.height / 2, globalGame.height / 2, -1'f32, -25'f32)
    of prHeight:
      game.width = globalGame.height * aspect
      game.projectionmatrix.OrthographicProjection(-globalGame.width / 2, globalGame.width / 2, -globalGame.height / 2, globalGame.height / 2, -1'f32, -25'f32)

  gl.glViewport(0, 0, cint(width), cint(height))
  game.gameScreen.textview = viewFromRect(floatRect(-globalGame.width / 2, -globalGame.height / 2, globalGame.width, globalGame.height))
  # 0 , 0, cfloat(width), cfloat(height)))



proc Perspective*(game: Game, fov, near, far: float32) =
  game.fov = fov
  game.near = near
  game.far = far
  game.projection = prProjection

  game.Resize(game.viewportWidth, game.viewportHeight)


proc SetOrthoWidth*(game: Game, width: float32) =
  game.width = width
  game.projection = prWidth

  game.Resize(game.viewportWidth, game.viewportHeight)


proc SetOrthoHeight*(game: Game, height: float32) =
  game.height = height
  game.projection = prHeight

  game.Resize(game.viewportWidth, game.viewportHeight)


proc GetOrthoWidth*(game: Game) : float32 =
  result = game.width

proc GetOrthoHeight*(game: Game) : float32 =
  result = game.height

proc Initialize(game: Game) =
    var contextSettings = newContextSettings(32, 0, 0, 2, 0)
    game.window = newRenderWindow(videoMode(cint(game.viewportWidth), cint(game.viewportHeight), 32), "SFML Example", sfDefaultStyle, addr(contextSettings))
    #game.window.setFramerateLimit(240)

    game.startTime = float32(sfml.getElapsedTime(game.clock).microseconds) / 1000000'f32

    gl.loadExtensions()

    game.Resize(game.viewportWidth, game.viewportHeight)
    game.SetScreen(game.gameScreen)


proc SetScreen*(game: Game, gameScreen: Screen) =
  echo "Set screen"
  if game.gameScreen != nil:
    game.gameScreen.Dispose

  game.gameScreen = gameScreen
  game.gameScreen.window = game.window
  game.Resize(game.viewportWidth, game.viewportHeight)
  game.gameScreen.Init


proc Update*(game: Game) =
  game.currentTime = float32(sfml.getElapsedTime(game.clock).microseconds) / 1000000'f32
  var frameDelta = game.currentTime - game.lastTime
  game.lastTime = game.currentTime

  #echo("DELTA: $1" % formatFloat(frameDelta, ffDefault, 9))

  if game.currentTime - game.lastFPSTime > 1.0:
      var frameRate = float(game.frameCount) / (game.currentTime - game.lastFPSTime)
      echo("FPS: $1" % formatFloat(frameRate, ffDefault, 6))

      game.lastFPSTime = game.currentTime
      game.frameCount = 0

  game.frameCount += 1
  game.gameScreen.Update(frameDelta)


proc Render*(game: Game) =
  game.gameScreen.Render()

  #GC_step(1000)


proc Stop*(game: Game) =
  game.running = false


proc Dispose(game: Game) =
  game.Stop()
  game.gameScreen.Dispose()


proc Run*(game: Game) =
  var evt: TEvent
  #GC_disable()
  game.running = true

  while game.running:
    while game.window.pollEvent(evt):
      case evt.kind
      of evtclosed:
        game.running = false
      of evtresized:
        game.Resize(evt.size.width, evt.size.height)
      of EvtKeyReleased:
        game.gameScreen.KeyUp(evt.key.code)
      else: discard

    game.Update()

    game.window.clear(game.clearColor)
    game.Render()

    game.window.display()


  game.gameScreen.Dispose
