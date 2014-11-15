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

attribute vec4 a_coords;
attribute vec4 a_position;
attribute vec2 a_texCoord;
attribute float a_size;
attribute float a_angle;

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

mat4 scale(float scale) {
    return mat4(
        vec4(scale, 0.0,   0.0,   0.0),
        vec4(0.0,   scale, 0.0,   0.0),
        vec4(0.0,   0.0,   scale, 0.0),
        vec4(0.0,   0.0,   0.0,   1.0)
    );
}

mat4 rotateZ(float angle) {
    return mat4(
        vec4(cos(angle),   sin(angle),  0.0,  0.0),
        vec4(-sin(angle),  cos(angle),  0.0,  0.0),
        vec4(0.0,          0.0,         1.0,  0.0),
        vec4(0.0,          0.0,         0.0,  1.0)
    );
}


void main() {
    mat4 rot = rotateZ(a_angle);
    mat4 scale = scale(a_size);
    mat4 trans = translate(a_position.x, a_position.y, -1);

    gl_Position =  u_pMatrix * trans * rot * scale * a_coords;
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
    width, height: float32


var
  program: PShaderProgram


proc textureMeshSetter(program: PShaderProgram, userdata: pointer) =
  var txt: Texture = cast[Texture](userdata)

  gl.glEnable(GL_TEXTURE_2D)
  gl.glEnable(GL_BLEND)
  gl.glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)

  gl.glActiveTexture(GL_TEXTURE0);

  sfml.bindGL(txt.sfmlTexture)

  program.SetUniformMatrix("u_pMatrix", ludens.projectionmatrix.Address)
  program.SetUniform1i("u_texture", 0)


proc initTexture(): Texture =
  result = Texture()

  if program == nil:
    program = createShaderProgram(vert, frag)

  result.mesh = createMesh(program, textureMeshSetter, cast[pointer](result), GL_TRIANGLES,
                 @[TMeshAttr(attribute: "a_coords", numberOfElements: 2),
                   TMeshAttr(attribute: "a_position", numberOfElements: 2),
                   TMeshAttr(attribute: "a_texCoord", numberOfElements: 2),
                   TMeshAttr(attribute: "a_size", numberOfElements: 1),
                   TMeshAttr(attribute: "a_angle", numberOfElements: 1)
                    ] )



proc createTexture*(file: string): Texture =
  result = initTexture()
  result.sfmlTexture = sfml.newTexture(file, nil)
  result.width = float32(result.sfmlTexture.getSize().x)
  result.height = float32(result.sfmlTexture.getSize().y)
  result.countx = 1
  result.county = 1
  result.frames = 1
  result.currentFrame = 1


proc createTexture*(file: string, x,y,frames: int, frameTime: float32): Texture =
  result = initTexture()
  result.sfmlTexture = sfml.newTexture(file, nil)
  result.width = float32(result.sfmlTexture.getSize().x) / float32(x)
  result.height = float32(result.sfmlTexture.getSize().y) / float32(y)
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
  txt.mesh.Draw()

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

  txt.mesh.AddVertices( -w/2, -h/2,  x+w/2, y+h/2 ,  tx     , ty + yh   , 1'f32, 0'f32 )
  txt.mesh.AddVertices( +w/2, -h/2,  x+w/2, y+h/2 ,  tx + xw, ty + yh   , 1'f32, 0'f32  )
  txt.mesh.AddVertices( +w/2, +h/2,  x+w/2, y+h/2 ,  tx + xw, ty        , 1'f32, 0'f32 )

  txt.mesh.AddVertices( +w/2, +h/2,  x+w/2, y+h/2 ,  tx + xw, ty         , 1'f32, 0'f32 )
  txt.mesh.AddVertices( -w/2, +h/2,  x+w/2, y+h/2 ,  tx     , ty         , 1'f32, 0'f32 )
  txt.mesh.AddVertices( -w/2, -h/2,  x+w/2, y+h/2 ,  tx     , ty + yh    , 1'f32, 0'f32 )


proc draw*(txt: Texture, x,y,w,h: float32) =
  txt.draw(x,y,w,h,txt.currentFrame)

proc draw*(txt: Texture, x,y: float32, frame: int) =
  var actualFrame = frame mod txt.frames

  var xw = 1'f32 / float32(txt.countx)
  var yh = 1'f32 / float32(txt.county)

  var tx = float32(actualFrame mod txt.countx) * xw
  var ty = float32(int(actualFrame / txt.countx)) * yh

  txt.mesh.AddVertices(    -txt.width/2, -txt.height/2,  x,y,  tx     , ty + yh    , 1'f32, 0'f32 )
  txt.mesh.AddVertices(    +txt.width/2, -txt.height/2,  x,y,  tx + xw, ty + yh    , 1'f32, 0'f32 )
  txt.mesh.AddVertices(    +txt.width/2, +txt.height/2,  x,y,  tx + xw, ty         , 1'f32, 0'f32 )

  txt.mesh.AddVertices(    +txt.width/2, +txt.height/2,  x,y,  tx + xw, ty         , 1'f32, 0'f32 )
  txt.mesh.AddVertices(    -txt.width/2, +txt.height/2,  x,y,  tx     , ty         , 1'f32, 0'f32 )
  txt.mesh.AddVertices(    -txt.width/2, -txt.height/2,  x,y,  tx     , ty + yh    , 1'f32, 0'f32 )


proc draw*(txt: Texture, x,y: float32) =
  txt.mesh.AddVertices(    -txt.width/2, -txt.height/2,  x,y,  0'f32  , 1'f32   , 1'f32, 0'f32 )
  txt.mesh.AddVertices(    +txt.width/2, -txt.height/2,  x,y,  1'f32  , 1'f32   , 1'f32, 0'f32 )
  txt.mesh.AddVertices(    +txt.width/2, +txt.height/2,  x,y,  1'f32  , 0'f32   , 1'f32, 0'f32 )

  txt.mesh.AddVertices(    +txt.width/2, +txt.height/2,  x,y,  1'f32  , 0'f32   , 1'f32, 0'f32 )
  txt.mesh.AddVertices(    -txt.width/2, +txt.height/2,  x,y,  0'f32  , 0'f32   , 1'f32, 0'f32 )
  txt.mesh.AddVertices(    -txt.width/2, -txt.height/2,  x,y,  0'f32  , 1'f32   , 1'f32, 0'f32 )


proc drawScaled*(txt: Texture, x, y, scale, angle: float32, frame: int) =
  var actualFrame = frame mod txt.frames

  var xw = 1'f32 / float32(txt.countx)
  var yh = 1'f32 / float32(txt.county)

  var tx = float32(actualFrame mod txt.countx) * xw
  var ty = float32(int(actualFrame / txt.countx)) * yh

  txt.mesh.AddVertices(    -txt.width/2, -txt.height/2,  x, y,  tx     , ty + yh  , scale, angle )
  txt.mesh.AddVertices(    +txt.width/2, -txt.height/2,  x, y,  tx + xw, ty + yh  , scale, angle )
  txt.mesh.AddVertices(    +txt.width/2, +txt.height/2,  x, y,  tx + xw, ty       , scale, angle )

  txt.mesh.AddVertices(    +txt.width/2, +txt.height/2,  x, y,  tx + xw, ty       , scale, angle )
  txt.mesh.AddVertices(    -txt.width/2, +txt.height/2,  x, y,  tx     , ty       , scale, angle )
  txt.mesh.AddVertices(    -txt.width/2, -txt.height/2,  x, y,  tx     , ty + yh  , scale, angle )


proc drawScaled*(txt: Texture, x,y, scale, angle: float32) =
  txt.mesh.AddVertices(    -txt.width/2, -txt.height/2,  x, y,  0'f32  , 1'f32   , scale, angle )
  txt.mesh.AddVertices(    +txt.width/2, -txt.height/2,  x, y,  1'f32  , 1'f32   , scale, angle )
  txt.mesh.AddVertices(    +txt.width/2, +txt.height/2,  x, y,  1'f32  , 0'f32   , scale, angle )

  txt.mesh.AddVertices(    +txt.width/2, +txt.height/2,  x, y,  1'f32  , 0'f32   , scale, angle )
  txt.mesh.AddVertices(    -txt.width/2, +txt.height/2,  x, y,  0'f32  , 0'f32   , scale, angle )
  txt.mesh.AddVertices(    -txt.width/2, -txt.height/2,  x, y,  0'f32  , 1'f32   , scale, angle )
