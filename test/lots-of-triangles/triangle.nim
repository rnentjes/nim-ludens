
type
  TTriangle = object
    x: float32
    y: float32
    z: float32
    rx: float32
    ry: float32
    rz: float32
  PTriangle* = ref TTriangle

proc Draw*() =

