import os
import strutils

import opengl as gl
import csfml as sfml

import game
import matrix
import shaderprogram
import mesh

# shaders
const
  vert: string = """
#if __VERSION__ >= 130
  #define attribute in
  #define varying out
#endif

#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

attribute vec4 a_position;
attribute float a_size;
attribute vec4 a_color;

uniform mat4 u_pMatrix;

varying vec4 v_color;

void main() {
  gl_Position = u_pMatrix * a_position;
  gl_PointSize = a_size;
  v_color = a_color;
}
  """

  frag: string = """
#if __VERSION__ >= 130
  #define varying in
  out vec4 mgl_FragColor;
  #define texture2D texture
  #define gl_FragColor mgl_FragColor
#endif

#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif


varying vec4 v_color;

void main() {
  float alpha = 1 - smoothstep(0, 1, 2 * distance(gl_PointCoord.st, vec2(0.5, 0.5)));

  gl_FragColor = vec4(v_color.rgb, v_color.a * alpha);
}
  """

type
  ParticleMesh* = ref object of TObject
    mesh: PMesh
    program: PShaderProgram


proc particleMeshSetter(program: PShaderProgram, userdata: pointer) =
  var pmesh: ParticleMesh = cast[ParticleMesh](userdata)

  gl.glEnable(GL_BLEND)
  gl.glBlendFunc(GL_SRC_ALPHA, GL_DST_ALPHA)

  gl.glEnable(GL_POINT_SMOOTH)
  gl.glEnable(GL_PROGRAM_POINT_SIZE)
  gl.glEnable(GL_POINT_SPRITE_OES)

  program.SetUniformMatrix("u_pMatrix", ludens.projectionmatrix.Address)


proc createParticleMesh*(): ParticleMesh =
  result = ParticleMesh()

  result.program = createShaderProgram(vert, frag)

  result.mesh = createMesh(result.program, particleMeshSetter, cast[pointer](result), GL_POINTS,
                 @[TMeshAttr(attribute: "a_position", numberOfElements: 3),
                   TMeshAttr(attribute: "a_size", numberOfElements: 1),
                   TMeshAttr(attribute: "a_color", numberOfElements: 4)
                   ] )


proc Dispose*(particleMesh: ParticleMesh) =
  particleMesh.mesh.Dispose()


proc flush*(particleMesh: ParticleMesh) =
  particleMesh.mesh.Draw()


proc draw*(particleMesh: ParticleMesh, x, y, z, size, r, g, b, a: float32) =
  particleMesh.mesh.AddVertices(  x,  y,  z,  size, r,  g,  b, a)
