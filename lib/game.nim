import src/glfw3 as glfw
import opengl as gl
import IL, ILU
import strutils

import screen
import matrix

type
  Game* = ref object of TObject
    gameScreen*: Screen
    running: bool
    startTime: cdouble
    window: glfw.Window
    title*: string
    lastTime, currentTime, lastFPSTime: float32
    frameCount: int
    width, height: float32
    projectionmatrix*: PMatrix


var
  #global
  globalGame*: Game


proc Dispose(game: Game)

proc create*(title: string = "Ludens", startScreen: Screen): Game =
  if globalGame != nil:
    globalGame.Dispose()

  globalGame = Game()
  globalGame.running = false
  globalGame.title = title
  globalGame.gameScreen = startScreen
  globalGame.lastTime = glfw.getTime()
  globalGame.currentTime = glfw.getTime()
  globalGame.lastFPSTime = 0
  globalGame.frameCount = 0
  globalGame.projectionmatrix = createMatrix()

  result = globalGame


proc KeyInput(window: glfw.Window, key, scancode, action, mods: cint) {.cdecl.} =
  echo "key: " & intToStr(key) & ", " & intToStr(scancode) & ", " & intToStr(action)

  if action == PRESS:
    globalGame.gameScreen.KeyDown(key, scancode, mods)
  elif action == RELEASE:
    globalGame.gameScreen.KeyUp(key, scancode, mods)
  elif action == REPEAT:
    globalGame.gameScreen.KeyRepeat(key, scancode, mods)


proc Resize(window: glfw.Window; width, height: cint) {.cdecl.} =
  globalGame.width = float32(width)
  globalGame.height = float32(height)

  #resized = true
  echo("Resize: ", intToStr(width), ", ", intToStr(height))

  globalGame.gameScreen.Resize(width, height)

  globalGame.projectionmatrix.PerspectiveProjection(75.0'f32, globalGame.width / globalGame.height, 0.1'f32, 30.0'f32)
  gl.glViewport(0, 0, width, height)


proc Initialize(game: Game) =
    game.startTime = glfw.GetTime()

    ilInit()
    #iluInit()

    if glfw.Init() == 0:
        write(stdout, "Could not initialize GLFW! \n")

    glfw.WindowHint(RESIZABLE, GL_TRUE)
    #glfw.WindowHint(GLFW_CLIENT_API, GLFW_OPENGL_ES_API)
    glfw.WindowHint(CONTEXT_VERSION_MAJOR, 2)
    glfw.WindowHint(CONTEXT_VERSION_MINOR, 0)
    glfw.WindowHint(OPENGL_DEBUG_CONTEXT, GL_TRUE)

    #glfw.OpenWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_COMPAT_PROFILE)

    # GLFW_WINDOW or GLFW_FULLSCREEN
    var monitor = glfw.GetPrimaryMonitor();
    var videoMode = glfw.GetVideoMode(monitor);
    game.window =  glfw.CreateWindow(cint(800), cint(600), game.title, nil, nil)
    #game.window =  glfw.CreateWindow(videoMode.width, videoMode.height, game.title, monitor, nil)

    glfw.MakeContextCurrent(game.window)

    glfw.SwapInterval(1)

    gl.loadExtensions()

    Resize(game.window, 800, 600)
    game.gameScreen.Init

    discard glfw.SetWindowSizeCallback(game.window, Resize)
    discard glfw.SetKeyCallback(game.window, KeyInput)


proc SetScreen*(game: Game, gameScreen: Screen) =
  echo "Set screen"
  game.gameScreen.Dispose
  game.gameScreen = gameScreen
  game.gameScreen.Init


proc Update*(game: Game) =
  game.currentTime = glfw.GetTime()
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
  #GC_disable()
  game.running = true

  game.Initialize

  while(game.running):
    # game loop
    glfw.PollEvents()

    game.Update()
    game.Render()
    glfw.SwapBuffers(game.window)

    game.running = game.running and
                   (glfw.GetKey(game.window, glfw.KEY_ESCAPE) != glfw.PRESS) and
                   glfw.windowShouldClose(game.window) != gl.GL_TRUE

  game.gameScreen.Dispose
