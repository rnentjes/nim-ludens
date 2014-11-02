import streams
import os

import opengl as gl

import matrix
import shaderprogram
import mesh

type
  Texture* = ref object of TObject
    glid: GLuint
    program: PShaderProgram
    mesh: PMesh
    pmatrix: PMatrix
    mmatrix: PMatrix

var
  program: PShaderProgram

  vert: string = """
#version 120

attribute vec4 a_position;
attribute vec2 a_texCoord;

uniform mat4 u_pMatrix;
uniform mat4 u_mMatrix;

varying vec2 v_texCoords;

mat4 translate(float x, float y, float z) {
    return mat4(
        vec4(1.0, 0.0, 0.0, 0.0),
        vec4(0.0, 1.0, 0.0, 0.0),
        vec4(0.0, 0.0, 1.0, 0.0),
        vec4(x,   y,   z,   1.0)
    );
}

void main() {
    gl_Position =  u_pMatrix * u_mMatrix * a_position;
    v_texCoords = a_texCoord;
}
  """

  frag: string = """
#version 120

#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D u_texture;

varying vec2 v_texCoords;

void main() {
    gl_FragColor = texture2D(u_texture, v_texCoords);
}
  """

proc loadFile(filename: string): pointer
proc loadRawTexture(width, height: int, data: pointer) : GLuint


proc textureMeshSetter(program: PShaderProgram, userdata: pointer) =
  var txt: Texture = cast[Texture](userdata)

  program.SetUniformMatrix("u_pMatrix", txt.pmatrix.Address)
  program.SetUniformMatrix("u_mMatrix", txt.mmatrix.Address)
  program.SetUniform1i("u_texture", 0)

  gl.glActiveTexture(GL_TEXTURE0);
  gl.glBindTexture(GL_TEXTURE_2D, txt.glid);


proc initTexture(): Texture =
  result = Texture()

  if program == nil:
    program = createShaderProgram(vert, frag)

  result.mmatrix = createMatrix()
  result.pmatrix = createMatrix()

  result.mesh = createMesh(program, textureMeshSetter, cast[pointer](result), GL_TRIANGLES,
                 @[TMeshAttr(attribute: "a_position", numberOfElements: 3),
                   TMeshAttr(attribute: "a_texCoord", numberOfElements: 2) ] )


proc createRawTexture*(file: string, width,height: int): Texture =
  result = initTexture()

  var data = loadFile(file)
  result.glid = loadRawTexture(width, height, data)
  dealloc(data)


proc dispose*(txt: Texture) =
  gl.glDeleteTextures(1, addr(txt.glid))


proc draw*(txt: Texture, x,y,w,h: float32) =
  gl.glEnable(GL_TEXTURE_2D)
  gl.glEnable(GL_BLEND)
  gl.glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)

  txt.pmatrix.PerspectiveProjection(75.0'f32, 800'f32 / 600'f32, 0.1'f32, 30.0'f32)
  #txt.pmatrix.Rotatez(angle)

  txt.mesh.AddVertices( -1'f32,  -1'f32,  -2'f32,  0'f32, 1'f32 )
  txt.mesh.AddVertices(  1'f32,  -1'f32,  -2'f32,  1'f32, 1'f32 )
  txt.mesh.AddVertices(  1'f32,   1'f32,  -2'f32,  1'f32, 0'f32 )

  txt.mesh.AddVertices(  1'f32,   1'f32,  -2'f32,  1'f32, 0'f32 )
  txt.mesh.AddVertices( -1'f32,   1'f32,  -2'f32,  0'f32, 0'f32 )
  txt.mesh.AddVertices( -1'f32,  -1'f32,  -2'f32,  0'f32, 1'f32 )

  txt.mesh.Draw()

  discard


proc flush() =
  discard


proc loadRawTexture(width, height: int, data: pointer) : GLuint =
  gl.glGenTextures(1, addr(result))

  gl.glActiveTexture(GL_TEXTURE0);
  gl.glBindTexture(GL_TEXTURE_2D, result);

  gl.glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, cast[GLsizei](width), cast[GLsizei](height), 0, GL_RGBA, GL_UNSIGNED_BYTE, data);

  gl.glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  gl.glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);


proc loadFile(filename: string): pointer =
  var size = getFileSize(filename)

  echo "size: ", size

  var file = open(filename)

  if file != nil:
    result = alloc(int(size))
    var instream = newFileStream(file)

    var bytesRead = readData(instream, result, int(size))

    if bytesRead != size:
      # error
      echo "Bytes read != file size!"
      discard

