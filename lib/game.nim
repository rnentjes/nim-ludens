import src/glfw3 as glfw
import opengl as gl
import screen
import strutils

type
  Game* = ref object of TObject
    gameScreen*: Screen
    running: bool
    startTime: cdouble
    window: glfw.Window

var
  #global
  globalGame: Game

proc Resize(window: glfw.Window; width, height: cint) {.cdecl.} =
    #windowW = float32(width)
    #windowH = float32(height)

    #resized = true
    echo("Resize: ", intToStr(width), ", ", intToStr(height))

    globalGame.gameScreen.Resize(width, height)

proc Initialize(game: Game) =
    game.startTime = glfw.GetTime()

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
    game.window =  glfw.CreateWindow(cint(800), cint(600), "TEST", nil, nil)
    #window =  glfw.CreateWindow(videoMode.width, videoMode.height, "TEST", monitor, nil)

    glfw.MakeContextCurrent(game.window)

    glfw.SwapInterval(1)

    gl.loadExtensions()

    game.gameScreen.Init

    discard glfw.SetWindowSizeCallback(game.window, Resize)

proc SetScreen*(game: Game, gameScreen: Screen) =
  game.gameScreen.Dispose
  game.gameScreen = gameScreen

proc Render*(game: Game, delta: float32) =
  game.gameScreen.Render(delta)

proc Stop*(game: Game) =
  game.running = false

proc Run*(game: Game) =
  game.running = true

  game.Initialize
  game.gameScreen.Init

  while(game.running):
    # game loop
    game.Render(0.16)
    glfw.SwapBuffers(game.window)
