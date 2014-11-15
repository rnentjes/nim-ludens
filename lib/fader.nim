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
attribute vec4 a_color;

uniform mat4 u_pMatrix;

varying vec4 v_color;

void main() {
  gl_Position = u_pMatrix * a_position;
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
  gl_FragColor = v_color.rgba;
}
  """

type
  Fader* = ref object of TObject
    mesh: PMesh
    program: PShaderProgram


proc faderMeshSetter(program: PShaderProgram, userdata: pointer) =
  var fader: Fader = cast[Fader](userdata)

  gl.glEnable(GL_BLEND)
  gl.glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)

  program.SetUniformMatrix("u_pMatrix", ludens.projectionmatrix.Address)


proc createFader*(): Fader =
  result = Fader()

  result.program = createShaderProgram(vert, frag)

  result.mesh = createMesh(result.program, faderMeshSetter, cast[pointer](result), GL_TRIANGLES,
                 @[TMeshAttr(attribute: "a_position", numberOfElements: 3),
                   TMeshAttr(attribute: "a_color", numberOfElements: 4)
                   ] )


proc Dispose*(fm: Fader) =
  fm.mesh.Dispose()


proc Fade*(fm: Fader, r,g,b,a: float32) =
  var w = ludens.GetOrthoWidth()
  var h = ludens.GetOrthoHeight()

  fm.mesh.AddVertices(-w/2, -h/2, -1'f32, r, g, b, a)
  fm.mesh.AddVertices( w/2, -h/2, -1'f32, r, g, b, a)
  fm.mesh.AddVertices( w/2,  h/2, -1'f32, r, g, b, a)

  fm.mesh.AddVertices( w/2,  h/2, -1'f32, r, g, b, a)
  fm.mesh.AddVertices(-w/2,  h/2, -1'f32, r, g, b, a)
  fm.mesh.AddVertices(-w/2, -h/2, -1'f32, r, g, b, a)

  fm.mesh.Draw()



