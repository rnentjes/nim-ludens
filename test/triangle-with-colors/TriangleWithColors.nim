import glfw
import opengl
import strutils
import typeinfo
import math
 
## -------------------------------------------------------------------------------
 
var
    running : bool = true
    frameCount: int = 0
    lastTime: float = 0.0
    lastFPSTime: float = 0.0
    currentTime: float = 0.0
    frameRate: int = 0
    frameDelta: float = 0.0
   
    windowW: GLint = 800
    windowH: GLint = 400
 
    vshaderID: int
    fshaderID: int
    shaderProg: int
 
    vertexPosAttrLoc: GLuint
    colorPosAttrLoc: GLuint
    
    startTime: cdouble

    vertex_vbo: GLuint
    color_vbo: GLuint
 
type
    ShaderType = enum
        VertexShader,
        FragmentShader

## -------------------------------------------------------------------------------

proc Resize(width: GLint, height: int32) =
   
    glViewport(0, 0, width, height)
 
## -------------------------------------------------------------------------------
 
proc LoadShader(shaderType: ShaderType, file: string ): int =
    
    if shaderType == VertexShader:
        result = glCreateShader(GL_VERTEX_SHADER)
       
    else:
        result = glCreateShader(GL_FRAGMENT_SHADER)
 
    if result == -1:
        quit("Error compiling shaders! Can't get shader handle!")
        
    var shaderSrc = readFile(file)
 
    var shader = result
 
    var stringArray = allocCStringArray([shaderSrc])
 
    glShaderSource(shader, 1 , stringArray, nil)
 
    deallocCStringArray(stringArray)
 
    glCompileShader(shader)
 
    var compileResult : GLInt
 
    glGetShaderiv(shader, GL_COMPILE_STATUS, addr(compileResult))
 
    if compileResult != GL_TRUE:
        result = -1

        var logLength : GLInt
        glGetShaderiv(shader, GL_INFO_LOG_LENGTH, addr(logLength))

        var log : cstring = cast[cstring](alloc0(logLength))
        glGetShaderInfoLog(shader, logLength, logLength, log)
        echo ("Error compiling the shader: ", file, " error: ", log)
 
        dealloc(log)

## ---------------------------------------------------------------------
 
proc InitializeGL() =

    glClearColor(0.2,0.0,0.2,1.0)
    
## ---------------------------------------------------------------------
 
proc InitializeShaders() =
   
    vshaderID = LoadShader(ShaderType.VertexShader, "vertexshader.vert")
    fshaderID = LoadShader(ShaderType.FragmentShader, "fragshader.frag")
 
    if vshaderID == -1 or fshaderID == -1:
        quit("Error compiling shaders! Can't get shader handles!")
 
    shaderProg = glCreateProgram()
 
    glAttachShader(shaderProg, vshaderID)
    glAttachShader(shaderProg, fshaderID)
 
    glLinkProgram(shaderProg)
 
    var linkStatus : GLint
 
    glGetProgramiv(shaderProg, GL_LINK_STATUS, addr(linkStatus))
 
    if linkStatus != GL_TRUE:
        quit("Error linking shader program!")
 
    glUseProgram(shaderProg)
 
    vertexPosAttrLoc = cast[GLUint](glGetAttribLocation(shaderProg, "a_position"))
    colorPosAttrLoc = cast[GLUint](glGetAttribLocation(shaderProg, "a_color"))
 
## -----------------------------------------------------------------------------
 
proc InitializeBuffers() =
   
    var vertices = [ 0.0'f32,   0.5'f32,  0.0'f32, 
                    -0.5'f32,  -0.5'f32,  0.0'f32, 
                     0.5'f32,  -0.5'f32,  0.0'f32,
                   ]
 
    glGenBuffers(1, addr(vertex_vbo))
 
    glBindBuffer(GL_ARRAY_BUFFER, vertex_vbo)
 
    glBufferData(GL_ARRAY_BUFFER, sizeof(GL_FLOAT) * vertices.len, addr(vertices[0]), GL_STATIC_DRAW)
 
    var colors = [   1.0'f32,   1.0'f32,  0.0'f32, 
                     0.0'f32,   1.0'f32,  1.0'f32, 
                     1.0'f32,   0.0'f32,  1.0'f32,
                   ]
 
    glGenBuffers(1, addr(color_vbo))
 
    glBindBuffer(GL_ARRAY_BUFFER, color_vbo)
 
    glBufferData(GL_ARRAY_BUFFER, sizeof(GL_FLOAT) * colors.len, addr(colors[0]), GL_STATIC_DRAW)

## -------------------------------------------------------------------------------
 
proc Initialize() =
    startTime = glfwGetTime()
   
    if glfwInit() == 0:
        write(stdout, "Could not initialize GLFW! \n")
 
    glfwOpenWindowHint(GLFW_WINDOW_NO_RESIZE, GL_FALSE)
    glfwOpenWindowHint(GLFW_CLIENT_API, GLFW_OPENGL_ES_API)
    glfwOpenWindowHint(GLFW_OPENGL_VERSION_MAJOR, 2)
    glfwOpenWindowHint(GLFW_OPENGL_VERSION_MINOR, 0)
    glfwOpenWindowHint(GLFW_OPENGL_DEBUG_CONTEXT, GL_TRUE)
    
    #glfwOpenWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_COMPAT_PROFILE)
 
    # GLFW_WINDOW or GLFW_FULLSCREEN
    if glfwOpenWindow(cint(windowW), cint(windowH), 0, 0, 0, 0, 0, 0, GLFW_WINDOW) == 0:
        glfwTerminate()
 
 
    glfwSwapInterval(1)
 
    opengl.loadExtensions()
 
    InitializeGL()
 
    Resize(windowW, windowH)
 
    lastTime = glfwGetTime()
    lastFPSTime = lastTime
 
    InitializeShaders()
    InitializeBuffers()
 
 
## -------------------------------------------------------------------------------
proc Update() =
   
    currentTime = glfwGetTime()
 
    frameDelta = currentTime - lastTime
 
    lastTime = currentTime
 
    if currentTime - lastFPSTime > 1.0:
        frameRate = int(float(frameCount) / (currentTime - lastFPSTime))
        glfwSetWindowTitle("FPS: $1" % intToStr(frameRate))
        
        lastFPSTime = currentTime
        frameCount = 0
    
    var delta = currentTime - startTime

    frameCount += 1
 
## --------------------------------------------------------------------------------
 
proc Render() =
   
    glClear(GL_COLOR_BUFFER_BIT)
    
    glUseProgram(shaderProg)
    
    glBindBuffer(GL_ARRAY_BUFFER, vertex_vbo)
 
    glEnableVertexAttribArray(0)
    
    glVertexAttribPointer(vertexPosAttrLoc, 3'i32, cGL_FLOAT, false, 0'i32, nil)
    
    glBindBuffer(GL_ARRAY_BUFFER, color_vbo)
    
    glEnableVertexAttribArray(1)
    
    glVertexAttribPointer(colorPosAttrLoc, 3'i32, cGL_FLOAT, false, 0'i32, nil)

    glDrawArrays(GL_TRIANGLES, 0, 3)
 
    glUseProgram(0)
    
    glfwSwapBuffers()

## --------------------------------------------------------------------------------
 
proc Run() =

    while running:
   
        Update()
 
        Render()
        
        running = glfwGetKey(GLFW_KEY_ESC) == GLFW_RELEASE and
                  glfwGetWindowParam(GLFW_OPENED) == GL_TRUE
 
 
## ==============================================================================
 
Initialize()
 
Run()
 
glfwTerminate()
