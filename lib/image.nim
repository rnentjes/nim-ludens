import png
import opengl

proc loadTexture*(file: string): TGLuint =
  echo("file: ", file)
  var image = Open(file)
  echo("image: $image")


