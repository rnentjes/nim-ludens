import glfw
import opengl
import strutils
import typeinfo
 
## -------------------------------------------------------------------------------
 
var
    running : bool = true
    frameCount: int = 0
    lastTime: float = 0.0
    lastFPSTime: float = 0.0
    currentTime: float = 0.0
    frameRate: int = 0
    frameDelta: float = 0.0
   
    windowW: GLint = 640
    windowH: GLint = 480
 
    vshaderID: int
    fshaderID: int
    shaderProg: int
 
    vertexPosAttrLoc: GLuint
 
    pMatrixUniLoc: int
    mvMatrixUniLoc: int
 
    mvMatrix: array[0..15, float32] = [1.0'f32, 0.0'f32, 0.0'f32, 0.0'f32, 0.0'f32, 1.0'f32, 0.0'f32, 0.0'f32, 0.0'f32, 0.0'f32, 1.0'f32, 0.0'f32, 0.0'f32, 0.0'f32, 0.0'f32, 1.0'f32]
    pMatrix: array[0..15, float32]  = [1.0'f32, 0.0'f32, 0.0'f32, 0.0'f32, 0.0'f32, 1.0'f32, 0.0'f32, 0.0'f32, 0.0'f32, 0.0'f32, 1.0'f32, 0.0'f32, 0.0'f32, 0.0'f32, 0.0'f32, 1.0'f32]
 
    vbo: GLuint
 
type
    ShaderType = enum
        VertexShader,
        FragmentShader

## -------------------------------------------------------------------------------
 
proc GenOrthoMatrix(width: int, height: int, matrix: var array[0..15, float32]) =
   
    matrix[0] = 2.0 / float(width)
    matrix[1] = 0.0
    matrix[2] = 0.0
    matrix[3] = 0.0
   
    matrix[4] = 0.0
    matrix[5] = 2.0 / float(-height)
    matrix[6] = 0.0
    matrix[7] = 0.0
   
    matrix[8] = 0.0
    matrix[9] = 0.0
    matrix[10] = -1.0
    matrix[11] = 0.0
   
    matrix[12] = -1.0
    matrix[13] = 1.0
    matrix[14] = 0.0
    matrix[15] = 1.0
    
 
 
proc Resize(width: GLint, height: int32) =
   
    glViewport(0, 0, width, height)
 
    #GenOrthoMatrix(width, height, pMatrix)
 
 
 
 
## -------------------------------------------------------------------------------
 
proc LoadShader(shaderType: ShaderType, file: string ): int =
    
    if shaderType == VertexShader:
        result = glCreateShader(GL_VERTEX_SHADER)
       
    else:
        result = glCreateShader(GL_FRAGMENT_SHADER)
 
 
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
    glClearDepth(1.0)
    glEnable(GL_BLEND)
    glDisable(GL_DEPTH_TEST)
    
proc PrintOpenGLError() =

    nil


## ---------------------------------------------------------------------
 
proc InitializeShaders() =
   
    vshaderID = LoadShader(ShaderType.VertexShader, "vertexshader.vert")
    fshaderID = LoadShader(ShaderType.FragmentShader, "fragshader.frag")
 
    if vshaderID == -1 or fshaderID == -1:
        quit("Error compiling shaders!")
 
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
 
    glEnableVertexAttribArray(vertexPosAttrLoc)
 
    #pMatrixUniLoc = glGetUniformLocation(shaderProg, "uPMatrix")
    #mvMatrixUniLoc = glGetUniformLocation(shaderProg, "uMVMatrix")
 
 
## -----------------------------------------------------------------------------
 
proc InitializeBuffers() =
   
    #var vertices = [0.0'f32, 1.0'f32, 0.0'f32, -1.0'f32, -1.0'f32, 0.0'f32, 1.0'f32, -1.0'f32, 0.0'f32]
    #var vertices = [0.0, 0.0, 0.0, -1.0, -1.0, 0.0, 0.0, -1.0, 0.0]
    var vertices = [0.0'f32, 0.5'f32, 0.0'f32, -0.5'f32, -0.5'f32, 0.0'f32, 0.5'f32, -0.5'f32, 0.0'f32]
 
    glGenBuffers(1, addr(vbo))
 
    glBindBuffer(GL_ARRAY_BUFFER, vbo)
 
    glBufferData(GL_ARRAY_BUFFER, sizeof(GL_FLOAT) * vertices.len, addr(vertices[0]), GL_STATIC_DRAW)

 
## -------------------------------------------------------------------------------
 
proc SetMatrixUniforms() =
    #glUniformMatrix4fv(pMatrixUniLoc, 16, false, addr(pMatrix[0]))
    #glUniformMatrix4fv(mvMatrixUniLoc, 16, false, addr(mvMatrix[0]))
 
 
 
## -------------------------------------------------------------------------------
 
proc Initialize() =
   
    if glfwInit() == 0:
        write(stdout, "Could not initialize GLFW! \n")
 
    glfwOpenWindowHint(GLFW_WINDOW_NO_RESIZE, GL_TRUE)
 
    if glfwOpenWindow(cint(windowW), cint(windowH), 0, 0, 0, 0, 0, 0, GLFW_WINDOW) == 0:
        glfwTerminate()
 
 
    glfwSwapInterval(0)
 
    opengl.loadExtensions()
    #openglInit()
 
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

    frameCount += 1   
 
## --------------------------------------------------------------------------------
 
proc Render() =
   
    glClear(GL_COLOR_BUFFER_BIT)
    
    glUseProgram(shaderProg)
 
    glBindBuffer(GL_ARRAY_BUFFER, vbo)
    
    glEnableVertexAttribArray(0)
 
    glVertexAttribPointer(vertexPosAttrLoc, 3'i32, cGL_FLOAT, false, 0'i32, nil)
 
    SetMatrixUniforms()
 
    glDrawArrays(GL_TRIANGLES, 0, 3)
 
    glUseProgram(0)
    
    glfwSwapBuffers()
    
    #sleep(10)

 
## --------------------------------------------------------------------------------
 
proc Run() =

    #discard GC_disable   
    
    while running:
    
        #GC_step(500, true)
   
        Update()
 
        Render()
 
        running = glfwGetKey(GLFW_KEY_ESC) == GLFW_RELEASE and
                  glfwGetWindowParam(GLFW_OPENED) == GL_TRUE
 
 
## ==============================================================================
 
 
 
Initialize()
 
Run()
 
glfwTerminate()
