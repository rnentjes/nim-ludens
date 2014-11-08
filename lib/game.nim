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
    fullscreen: bool
    startTime: cdouble
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
    window*: sfml.PRenderWindow
    textview*: PView

var
  #global
  ludens*: Game


proc Dispose(game: Game)
proc Initialize(game: Game)
proc Resize(game: Game, width, height: int)
proc SetScreen*(game: Game, gameScreen: Screen)

proc create*(title: string = "Ludens", startScreen: Screen, fullscreen: bool = false, width: int = 800, height: int = 600): Game =
  if ludens != nil:
    ludens.Dispose()

  result = Game()
  result.clock = newClock()
  result.running = false
  result.fullscreen = fullscreen
  result.title = title
  result.gameScreen = startScreen
  result.lastTime = 0'f32
  result.currentTime = 0'f32
  result.lastFPSTime = 0
  result.frameCount = 0
  result.projection = prProjection
  result.projectionmatrix = createMatrix()
  result.fov = 75'f32
  result.near = 1'f32
  result.far = 25'f32
  result.clearColor = sfml.color(20, 0, 20)
  result.viewportWidth = width
  result.viewportHeight = height

  result.Initialize()

  ludens = result


proc SetClearColor*(game: Game, clearColor: TColor) =
  game.clearColor = clearColor


proc Resize(game: Game, width, height: int) =
  game.viewportWidth = width
  game.viewportHeight = height

  game.window.setSize(vec2i(width, height))
  echo("Resize: ", intToStr(width), ", ", intToStr(height))

  var aspect = float32(game.viewportWidth) / float32(game.viewportHeight)
  case game.projection:
    of prProjection:
      game.projectionmatrix.PerspectiveProjection(75.0'f32, aspect, game.near, game.far)
    of prWidth:
      game.height = game.width / aspect
      game.projectionmatrix.OrthographicProjection(-game.width / 2, game.width / 2, -game.height / 2, game.height / 2, -1'f32, -25'f32)
    of prHeight:
      game.width = game.height * aspect
      game.projectionmatrix.OrthographicProjection(-game.width / 2, game.width / 2, -game.height / 2, game.height / 2, -1'f32, -25'f32)

  gl.glViewport(0, 0, cint(width), cint(height))
  game.textview = viewFromRect(floatRect(-game.width / 2, -game.height / 2, game.width, game.height))
  game.gameScreen.textview = game.textview


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
    if game.fullscreen:
      var videoMode = getDesktopMode()
      game.viewportWidth = videoMode.width
      game.viewportHeight = videoMode.height
      game.window = newRenderWindow(getDesktopMode(), game.title, sfFullscreen, addr(contextSettings))
    else:
      game.window = newRenderWindow(videoMode(cint(game.viewportWidth), cint(game.viewportHeight), 32), game.title, sfDefaultStyle, addr(contextSettings))

    #game.window.setFramerateLimit(120)
    #game.window.setVerticalSyncEnabled(true)

    game.startTime = float32(sfml.getElapsedTime(game.clock).microseconds) / 1000000'f32
    gl.loadExtensions()

    game.Resize(game.viewportWidth, game.viewportHeight)
    game.gameScreen.window = game.window
    game.gameScreen.textview = game.textview
    game.gameScreen.Init()


proc SetScreen*(game: Game, gameScreen: Screen) =
  echo "Set screen"
  if game.gameScreen != nil:
    game.gameScreen.Dispose()

  game.gameScreen = gameScreen
  game.gameScreen.window = game.window
  game.gameScreen.textview = game.textview
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
        if evt.key.code == KeyEscape:
          game.running = false
        game.gameScreen.KeyUp(evt.key.code)
      of EvtKeyPressed:
        game.gameScreen.KeyDown(evt.key.code)
      else: discard

    game.Update()

    game.window.clear(game.clearColor)
    game.Render()

    game.window.display()


  game.gameScreen.Dispose
