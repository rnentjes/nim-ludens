import streams
import os
import strutils

import opengl as gl
import csfml as sfml

import game
import matrix
import shaderprogram
import mesh

type
  Texture* = ref object of TObject
    sfmlTexture: PTexture
    glid: GLuint
    program: PShaderProgram
    mesh: PMesh

var
  program: PShaderProgram

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



proc dispose*(txt: Texture) =
  sfml.destroy(txt.sfmlTexture)
  #gl.glDeleteTextures(1, addr(txt.glid))


proc flush*(txt: Texture) =
  gl.glEnable(GL_TEXTURE_2D)
  gl.glEnable(GL_BLEND)
  gl.glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)

  gl.glActiveTexture(GL_TEXTURE0);

  sfml.bindGL(txt.sfmlTexture)

  txt.mesh.Draw()

  #gl.glBindTexture(GL_TEXTURE_2D, 0);


proc draw*(txt: Texture, x,y,w,h: float32) =
  txt.mesh.AddVertices(   x,   y,  -4'f32,  0'f32, 1'f32 )
  txt.mesh.AddVertices( x+w,   y,  -4'f32,  1'f32, 1'f32 )
  txt.mesh.AddVertices( x+w, y+h,  -4'f32,  1'f32, 0'f32 )

  if txt.mesh.BufferFull:
    txt.flush()

  txt.mesh.AddVertices( x+w, y+h,  -4'f32,  1'f32, 0'f32 )
  txt.mesh.AddVertices(   x, y+h,  -4'f32,  0'f32, 0'f32 )
  txt.mesh.AddVertices(   x,   y,  -4'f32,  0'f32, 1'f32 )

  if txt.mesh.BufferFull:
    txt.flush()

