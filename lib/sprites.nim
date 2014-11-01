import opengl as gl
import mesh

type
  Sprite = ref object of TObject
    x: float32
    y: float32
    texture: GLuint

  TSpriteBatch = object
    sprites: seq[Sprite]
    count: GLsizei

proc createSpriteBatch* =
  discard
