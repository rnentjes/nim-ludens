import src/glfw3 as glfw
import opengl as gl
import strutils
import typeinfo
import math

import perspective
import shaderProgram
import mesh
import matrix

## -------------------------------------------------------------------------------

type
    TTriangle = object
      x: float32
      y: float32
      z: float32
      size: float32
      angle: float32
      r: float32
      g: float32
      b: float32

var
    running : bool = true
    frameCount: int = 0
    lastTime: float = 0.0
    lastFPSTime: float = 0.0
    currentTime: float = 0.0
    frameRate: int = 0
    frameDelta: float = 0.0

    window: glfw.Window
    windowW: float32 = 1024'f32
    windowH: float32 = 768'f32

    startTime: cdouble

    mvpMatrixUniLoc: int

    pmatrix: PMatrix
    backmatrix: PMatrix
    mymatrix: PMatrix

    resized: bool = true

    shader: PShaderProgram
    mymesh: PMesh

    triangles: array[0..9999, TTriangle]

type
    ShaderType = enum
        VertexShader,
        FragmentShader

## -------------------------------------------------------------------------------

proc draw(tr: TTriangle, mesh: PMesh) =
  mesh.AddVertices( tr.x - tr.size, tr.y,  -2'f32, tr.r, tr.g, tr.b )
  mesh.AddVertices( tr.x + tr.size / 0.5'f32, tr.y + tr.size,  -2'f32, tr.r, tr.g, tr.b )
  mesh.AddVertices( tr.x + tr.size, tr.y,  -2'f32, tr.r, tr.g, tr.b )

proc Resize(window: glfw.Window; width, height: cint) {.cdecl.} =
    windowW = float32(width)
    windowH = float32(height)

    resized = true
    echo("Resize: ", intToStr(width), ", ", intToStr(height))

## ---------------------------------------------------------------------

proc InitializeGL() =
    glClearColor(0.2,0.0,0.2,1.0)

## -------------------------------------------------------------------------------

proc mymeshsetter(program: PShaderProgram, data: pointer) =
  program.SetUniformMatrix("u_pMatrix", pmatrix.Address)
  program.SetUniformMatrix("u_mMatrix", backmatrix.Address)

proc Initialize() =
    startTime = glfw.GetTime()

    #var text = loadTexture("SmallOwlAlpha.png")

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
    window =  glfw.CreateWindow(cint(windowW), cint(windowH), "TEST", nil, nil)
    #window =  glfw.CreateWindow(videoMode.width, videoMode.height, "TEST", monitor, nil)

    echo("Window: ")
    echo(cast[int64](window))

    glfw.MakeContextCurrent(window)

    glfw.SwapInterval(0)

    gl.loadExtensions()

    InitializeGL()

    lastTime = glfw.GetTime()
    lastFPSTime = lastTime

    shader = createShaderProgram("shaders/shader")

    mymesh = createMesh(shader, mymeshsetter, nil, GL_TRIANGLES,
        @[TMeshAttr(attribute: "a_position", numberOfElements: 3),
          TMeshAttr(attribute: "a_color", numberOfElements: 3)] )

    mymatrix = createMatrix()
    backmatrix = createMatrix()
    pmatrix = createMatrix()

    discard glfw.SetWindowSizeCallback(window, Resize)

    randomize()
    for i in countup(0, len(triangles)-1):
      triangles[i].x = random(2'f32) - 1'f32
      triangles[i].y = random(2'f32) - 1'f32
      triangles[i].z = random(2'f32) - 1'f32
      triangles[i].size = random(0.05'f32) + 0.1'f32
      triangles[i].angle = random(2'f32 * PI)
      triangles[i].r = random(0.75'f32) + 0.25'f32
      triangles[i].g = random(0.75'f32) + 0.25'f32
      triangles[i].b = random(0.75'f32) + 0.25'f32

## -------------------------------------------------------------------------------
proc Update() =
    currentTime = glfw.GetTime()

    frameDelta = currentTime - lastTime

    lastTime = currentTime

    if currentTime - lastFPSTime > 1.0:
        frameRate = int(float(frameCount) / (currentTime - lastFPSTime))
        echo("FPS: $1" % intToStr(frameRate))

        lastFPSTime = currentTime
        frameCount = 0

    var delta = currentTime - startTime

    frameCount += 1

## --------------------------------------------------------------------------------

proc Render() =

    gl.glClear(GL_COLOR_BUFFER_BIT)

    var z : float32

    z = float32(-15 + sin(currentTime / 3) * 14)
    var r = float32((1 + sin(currentTime * 2.7)) / 2.0)
    var g = float32((1 + sin(currentTime * 3.3)) / 2.0)
    var b = float32((1 + sin(currentTime * 4.5)) / 2.0)

    var r1 = float32((1 + sin(currentTime * 3.3)) / 2.0)
    var g1 = float32((1 + sin(currentTime * 4.5)) / 2.0)
    var b1 = float32((1 + sin(currentTime * 2.7)) / 2.0)

    backmatrix.Rotatez(frameDelta * 0.05'f32)
    mymatrix.Rotatez(frameDelta * 3'f32)
    #mymatrix.Rotatex(frameDelta * 0.7'f32)

    mymesh.AddVertices( -4'f32,  -4'f32,  -2'f32,  1-r1,  1-g1,   1-b1)
    mymesh.AddVertices(  4'f32,  -4'f32,  -2'f32,  r1,    g1,     b1)
    mymesh.AddVertices(  4'f32,   4'f32,  -2'f32,  g1,    b1,     r1)

    mymesh.AddVertices(  4'f32,   4'f32,  -2'f32,  g1,    b1,     r1)
    mymesh.AddVertices( -4'f32,  -4'f32,  -2'f32,  1-r1,  1-g1,   1-b1)
    mymesh.AddVertices( -4'f32,   4'f32,  -2'f32,  r1,    g1,     b1)

    for t in triangles:
      t.draw(mymesh)

    mymesh.Draw

    #glFlush()
    glfw.SwapBuffers(window)


## --------------------------------------------------------------------------------

proc Run() =
    #GC_disable()

    echo("Window: ")
    echo(cast[int64](window))

    while running:
        glfw.PollEvents()

        if resized:
          echo("Resizes: ", windowW, ", ", windowH)
          echo("Int    : ", int(windowW), ", ", int(windowH))
          resized = false

          glViewport(0, 0, cast[GLint](int(windowW)), cast[GLint](int(windowH)))
          pmatrix.PerspectiveProjection(75.0'f32, windowW / windowH, 0.1'f32, 30.0'f32)
          pmatrix.OrthographicProjection(-4'f32, 4'f32, -4'f32, 4'f32, -0.1'f32, -30.0'f32)

        Update()

        Render()

        #GC_step(1000)

        running = (glfw.GetKey(window, glfw.KEY_ESCAPE) != glfw.PRESS) and glfw.windowShouldClose(window) != gl.GL_TRUE

        if glfw.GetKey(window, glfw.KEY_ESCAPE) != glfw.RELEASE:
          echo("KEY_STATE: ", intToStr(glfw.GetKey(window, glfw.KEY_SPACE)))
        # and
        #          glfw.GetWindowAttrib(window, glfw.VISIBLE) == GL_TRUE


## ==============================================================================

Initialize()

Run()

Terminate()