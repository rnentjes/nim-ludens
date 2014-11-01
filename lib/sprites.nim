import opengl as gl
import mesh
import shaderprogram

type
  Sprite = ref object of TObject
    texture: GLuint

  SpriteBatch = ref object of TObject
    mesh: PMesh
    program: PShaderProgram
    pmatrix: PMatrix
    backmatrix: PMatrix


proc spriteMeshSetter(program: PShaderProgram, userdata: pointer) =
  var batch: SpriteBatch = cast[SpriteBatch](pointer)

  program.SetUniformMatrix("u_pMatrix", pmatrix.Address)
  program.SetUniformMatrix("u_mMatrix", backmatrix.Address)


proc createSpriteBatch*():SpriteBatch =
  result = SpriteBatch()

  result.program = createShaderProgram("sprites")

  result.backmatrix = createMatrix()
  result.pmatrix = createMatrix()

  result.mesh = createMesh(result.program, spriteMeshSetter, mesh, GL_TRIANGLES,
                 @[TMeshAttr(attribute: "a_position", numberOfElements: 3),
                   TMeshAttr(attribute: "a_color", numberOfElements: 3)] )


proc draw(txt: Texture, x,y,w,h: float32) =
  discard


proc flush() =
  discard
