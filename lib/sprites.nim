import opengl
import mesh

type
  TSprite = object
    x: float32
    y: float32
    texture: GLuint

  TSpriteBatch = object
    sprites: seq[TSprite]
    count: GLsizei

proc createSpriteBatch* =
  discard

  