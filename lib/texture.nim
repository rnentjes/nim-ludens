import streams
import os
import strutils

import opengl as gl
import csfml as sfml

import game
import matrix
import shaderprogram
import mesh


const
  vert: string = """
#version 120

attribute vec4 a_position;
attribute vec2 a_texCoord;

uniform mat4 u_pMatrix;

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
    gl_Position =  u_pMatrix * a_position;
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


type
  Texture* = ref object of TObject
    sfmlTexture: PTexture
    glid: GLuint
    program: PShaderProgram
    mesh: PMesh
    countx, county, frames, currentFrame: int
    frameTime, currentFrameTime: float32


var
  program: PShaderProgram


proc textureMeshSetter(program: PShaderProgram, userdata: pointer) =
  var txt: Texture = cast[Texture](userdata)

  program.SetUniformMatrix("u_pMatrix", ludens.projectionmatrix.Address)
  program.SetUniform1i("u_texture", 0)


proc initTexture(): Texture =
  result = Texture()

  if program == nil:
    program = createShaderProgram(vert, frag)

  result.mesh = createMesh(program, textureMeshSetter, cast[pointer](result), GL_TRIANGLES,
                 @[TMeshAttr(attribute: "a_position", numberOfElements: 3),
                   TMeshAttr(attribute: "a_texCoord", numberOfElements: 2)
                    ] )



proc createTexture*(file: string): Texture =
  result = initTexture()
  result.sfmlTexture = sfml.newTexture(file, nil)
  result.countx = 1
  result.county = 1
  result.frames = 1
  result.currentFrame = 1


proc createTexture*(file: string, x,y,frames: int, frameTime: float32): Texture =
  result = initTexture()
  result.sfmlTexture = sfml.newTexture(file, nil)
  result.countx = x
  result.county = y
  result.frames = frames
  result.currentFrame = 1
  result.currentFrameTime = 0
  result.frameTime = frameTime


proc Dispose*(txt: Texture) =
  sfml.destroy(txt.sfmlTexture)
  txt.mesh.Dispose()


proc flush*(txt: Texture) =
  gl.glEnable(GL_TEXTURE_2D)
  gl.glEnable(GL_BLEND)
  gl.glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)

  gl.glActiveTexture(GL_TEXTURE0);

  sfml.bindGL(txt.sfmlTexture)

  txt.mesh.Draw()

  #gl.glBindTexture(GL_TEXTURE_2D, 0);

proc Update*(txt: Texture, delta: float32) =
  txt.currentFrameTime += delta

  if txt.currentFrameTime > txt.frameTime:
    txt.currentFrameTime -= txt.frameTime
    txt.currentFrame = (txt.currentFrame + 1) mod txt.frames


proc draw*(txt: Texture, x,y,w,h: float32, frame: int) =
  var actualFrame = frame mod txt.frames


  var xw = 1'f32 / float32(txt.countx)
  var yh = 1'f32 / float32(txt.county)

  var tx = float32(actualFrame mod txt.countx) * xw
  var ty = float32(int(actualFrame / txt.countx)) * yh

  txt.mesh.AddVertices(   x,   y,  -4'f32,  tx     , ty + yh )
  txt.mesh.AddVertices( x+w,   y,  -4'f32,  tx + xw, ty + yh )
  txt.mesh.AddVertices( x+w, y+h,  -4'f32,  tx + xw, ty )

  if txt.mesh.BufferFull:
    txt.flush()

  txt.mesh.AddVertices( x+w, y+h,  -4'f32,  tx + xw, ty )
  txt.mesh.AddVertices(   x, y+h,  -4'f32,  tx     , ty )
  txt.mesh.AddVertices(   x,   y,  -4'f32,  tx     , ty + yh )

  if txt.mesh.BufferFull:
    txt.flush()

proc draw*(txt: Texture, x,y,w,h: float32) =
  txt.draw(x,y,w,h,txt.currentFrame)

