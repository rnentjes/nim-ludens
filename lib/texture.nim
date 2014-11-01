import streams
import os

import opengl as gl

import matrix

type
  Texture = ref object of TObject
    glid: GLuint
    program: PShaderProgram
    mesh: PMesh
    pmatrix: PMatrix
    backmatrix: PMatrix


proc loadFile(filename: string): pointer
proc loadRawTexture(width, height: int, data: pointer) : GLuint


proc spriteMeshSetter(program: PShaderProgram, userdata: pointer) =
  var txt: Texture = cast[Texture](pointer)

  program.SetUniformMatrix("u_pMatrix", pmatrix.Address)
  program.SetUniformMatrix("u_mMatrix", backmatrix.Address)


proc createRawTexture*(file: string, width,height: int): Texture =
  result = Texture()

  var data = loadFile(file)
  result.glid = loadRawTexture(width, height, addr(data))


proc dispose*(txt: Texture) =
  gl.glDeleteTextures(1, addr(txt.glid))


proc draw(txt: Texture, x,y,w,h: float32) =
  discard


proc flush() =
  discard


proc loadRawTexture(width, height: int, data: pointer) : GLuint =
  gl.glGenTextures(1, addr(result))

  gl.glActiveTexture(GL_TEXTURE0);
  gl.glBindTexture(GL_TEXTURE_2D, result);

  gl.glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, cast[GLsizei](width), cast[GLsizei](height), 0, GL_RGB, GL_UNSIGNED_BYTE, data);

  gl.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_LINEAR, GL.GL_LINEAR);
  gl.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_LINEAR, GL.GL_LINEAR);


proc loadFile(filename: string): pointer =
  var size = getFileSize(filename)

  var file = open(filename)

  if file != nil:
    result = alloc(int(size))
    var instream = newFileStream(file)

    var bytesRead = readData(instream, result, int(size))

    if bytesRead != size:
      # error
      discard

