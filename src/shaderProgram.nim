#shaderProgram
import opengl

type
  ShaderType = enum
    VertexShader,
    FragmentShader
        
  TShaderProgram = object
    handle: TGLuint
    vshaderID: GLuint
    fshaderID: GLuint
    
  PShaderProgram* = ref TShaderProgram

proc LoadShader(shaderType: ShaderType, file: string ): TGLuint

proc createShaderProgram*(name: string) : PShaderProgram =
  result = new(TShaderProgram)
  
  result.vshaderID = LoadShader(ShaderType.VertexShader, name & ".vert")
  result.fshaderID = LoadShader(ShaderType.FragmentShader, name & ".frag")
 
  if cast[int](result.vshaderID) == -1 or cast[int](result.fshaderID) == -1:
    quit("Error compiling shaders! Can't get shader handles!")
 
  result.handle = glCreateProgram()
 
  glAttachShader(result.handle, result.vshaderID)
  glAttachShader(result.handle, result.fshaderID)
 
  glLinkProgram(result.handle)
 
  var linkStatus : GLint
 
  glGetProgramiv(result.handle, GL_LINK_STATUS, addr(linkStatus))
 
  if linkStatus != GL_TRUE:
    quit("Error linking shader program!")


proc Begin*(program: PShaderProgram) =
  glUseProgram(program.handle)
  
  
proc Done*(program: PShaderProgram) =
  glUseProgram(0)
  

proc GetAttribLocation*(program: PShaderProgram, name: string) : GLuint =
  result = cast[GLuint](glGetAttribLocation(program.handle, name))

  
proc GetUniformLocation*(program: PShaderProgram, name: string) : GLint =
  result = glGetUniformLocation(program.handle, name)


proc SetUniformMatrix*(program: PShaderProgram, name: string, value: ptr float) =
  var location = glGetUniformLocation(program.handle, name)

  glUniformMatrix4fv(location, 1, false, cast[ptr GLfloat](value))

  
proc LoadShader(shaderType: ShaderType, file: string ): TGLuint =
    
    if shaderType == VertexShader:
        result = glCreateShader(GL_VERTEX_SHADER)
       
    else:
        result = glCreateShader(GL_FRAGMENT_SHADER)
 
    if int(result) == -1:
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
        result = cast[TGLuint](-1)

        var logLength : GLsizei
        glGetShaderiv(shader, GL_INFO_LOG_LENGTH, addr(logLength))

        var log : cstring = cast[cstring](alloc0(logLength))
        glGetShaderInfoLog(shader, logLength, addr(logLength), log)
        echo ("Error compiling the shader: ", file, " error: ", log)
 
        dealloc(log)
