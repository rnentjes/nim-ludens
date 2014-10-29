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
    
    mvpMatrixUniLoc: int

    pMatrix: array[0..15, float32]  = [1.0'f32, 0.0'f32, 0.0'f32, 0.0'f32, 
                                       0.0'f32, 1.0'f32, 0.0'f32, 0.0'f32, 
                                       0.0'f32, 0.0'f32, 1.0'f32, 0.0'f32, 
                                       0.0'f32, 0.0'f32, 0.0'f32, 1.0'f32]
 
    
 
type
    ShaderType = enum
        VertexShader,
        FragmentShader

## -------------------------------------------------------------------------------

proc DegToRad(deg: float32) :float32 =
    result = deg / (PI / 180.0)
        
proc OpenGlPerspective(angle: float32, imageAspectRatio: float32, n: float32, f: float32, matrix: var array[0..15, float32]) =
    var 
        r = DegToRad(angle)
        f = 1.0 / tan(r / 2.0)
        
    matrix[0] = f / imageAspectRatio
    matrix[1] = 0.0
    matrix[2] = 0.0
    matrix[3] = 0.0
   
    matrix[4] = 0.0
    matrix[5] = f
    matrix[6] = 0.0
    matrix[7] = 0.0
   
    matrix[8] = 0.0
    matrix[9] = 0.0
    matrix[10] = -(f + n) / (f - n)
    matrix[11] = -1.0
   
    matrix[12] = 0.0
    matrix[13] = 0.0
    matrix[14] = -(2.0 * f * n) / (f - n)
    matrix[15] = 0.0


proc Resize(width, height: cint) = 
    #glViewport(0, 0, width, height)

    OpenGlPerspective(60.0, float32(width) / float32(height), -1.0, -50.0, pMatrix)
 
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

    glViewport(0, 0, windowW, windowH)
    
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
    mvpMatrixUniLoc = glGetUniformLocation(shaderProg, "u_pMatrix")

## -----------------------------------------------------------------------------
 
proc InitializeBuffers() =
   
    var vertices = [ 0.0'f32,   0.5'f32,  -2.0'f32, 
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
 
    glfwSetWindowSizeCallback(Resize)
 
    glfwSwapInterval(1)
 
    opengl.loadExtensions()
 
    InitializeGL()
 
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
        echo("FPS: $1" % intToStr(frameRate))
        
        lastFPSTime = currentTime
        frameCount = 0
    
    var delta = currentTime - startTime

    frameCount += 1
 
## --------------------------------------------------------------------------------
 
proc Render() =
   
    glClear(GL_COLOR_BUFFER_BIT)
    
    glUseProgram(shaderProg)
    
    glUniformMatrix4fv(int32(mvpMatrixUniLoc), 1, false, addr(pMatrix[0]))

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
