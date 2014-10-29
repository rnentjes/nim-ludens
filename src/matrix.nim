import math

type
  TMatrix = object
    matrix: array[0..15, float32]
    tmp: array[0..15, float32]
    rz: array[0..15, float32]
    rx: array[0..15, float32]

  PMatrix* = ref TMatrix

proc DegToRad(deg: float32) :float32 =
    result = float32((deg / 180'f32) * math.PI)

proc SetToIdentity(matrix: var array[0..15, float32]) =
  matrix[ 0] = 1'f32
  matrix[ 1] = 0'f32
  matrix[ 2] = 0'f32
  matrix[ 3] = 0'f32

  matrix[ 4] = 0'f32
  matrix[ 5] = 1'f32
  matrix[ 6] = 0'f32
  matrix[ 7] = 0'f32

  matrix[ 8] = 0'f32
  matrix[ 9] = 0'f32
  matrix[10] = 1'f32
  matrix[11] = 0'f32

  matrix[12] = 0'f32
  matrix[13] = 0'f32
  matrix[14] = 0'f32
  matrix[15] = 1'f32

proc createMatrix*() : PMatrix =
  result = new(TMatrix)

  SetToIdentity(result.matrix)
  SetToIdentity(result.tmp)
  SetToIdentity(result.rz)
  SetToIdentity(result.rx)

proc Values*(matrix: PMatrix) : array[0..15, float32] =
  result = matrix.matrix

proc Address*(matrix: PMatrix) : ptr float =
  result = addr(matrix.matrix[0])
        
proc OrthographicProjection*(matrix: PMatrix, left: float32, right: float32, bottom: float32, top: float32, near: float32, far: float32) =
       
    matrix.matrix[0] = 2.0 / (right - left)
    matrix.matrix[1] = 0.0
    matrix.matrix[2] = 0.0
    matrix.matrix[3] = 0.0
   
    matrix.matrix[4] = 0.0
    matrix.matrix[5] = 2.0 / (top - bottom)
    matrix.matrix[6] = 0.0
    matrix.matrix[7] = 0.0
   
    matrix.matrix[8] = 0.0
    matrix.matrix[9] = 0.0
    matrix.matrix[10] = -2.0 / (far - near)
    matrix.matrix[11] = 0.0
   
    matrix.matrix[12] = (right + left) / (right - left)
    matrix.matrix[13] = (top + bottom) / (top - bottom)
    matrix.matrix[14] = (far + near) / (far - near)
    matrix.matrix[15] = 1.0

proc PerspectiveProjection*(matrix: PMatrix, angle: float32, imageAspectRatio: float32, near: float32, far: float32) =
    var 
        r = DegToRad(angle)
        f = float32(1.0'f32 / tan(r / 2.0'f32))

    echo("Rad: ", r)
    echo("Aspect: ", imageAspectRatio)
        
    matrix.matrix[0] = f / imageAspectRatio
    matrix.matrix[1] = 0.0'f32
    matrix.matrix[2] = 0.0'f32
    matrix.matrix[3] = 0.0'f32
   
    matrix.matrix[4] = 0.0'f32
    matrix.matrix[5] = f
    matrix.matrix[6] = 0.0'f32
    matrix.matrix[7] = 0.0'f32
   
    matrix.matrix[8] = 0.0'f32
    matrix.matrix[9] = 0.0'f32
    matrix.matrix[10] = -(far + near) / (far - near)
    matrix.matrix[11] = -1.0'f32
   
    matrix.matrix[12] = 0.0'f32
    matrix.matrix[13] = 0.0'f32
    matrix.matrix[14] = -(2.0'f32 * far * near) / (far - near)
    matrix.matrix[15] = 0.0'f32

proc Mul(matrix: PMatrix, other: array[0..15, float32]) =
  matrix.tmp[ 0] = matrix.matrix[ 0] * other[ 0] + matrix.matrix[ 1] * other[ 4] + matrix.matrix[ 2] * other[ 8] + matrix.matrix[ 3] * other[12]
  matrix.tmp[ 1] = matrix.matrix[ 0] * other[ 1] + matrix.matrix[ 1] * other[ 5] + matrix.matrix[ 2] * other[ 9] + matrix.matrix[ 3] * other[13]
  matrix.tmp[ 2] = matrix.matrix[ 0] * other[ 2] + matrix.matrix[ 1] * other[ 6] + matrix.matrix[ 2] * other[10] + matrix.matrix[ 3] * other[14]
  matrix.tmp[ 3] = matrix.matrix[ 0] * other[ 3] + matrix.matrix[ 1] * other[ 7] + matrix.matrix[ 2] * other[11] + matrix.matrix[ 3] * other[15]
  matrix.tmp[ 4] = matrix.matrix[ 4] * other[ 0] + matrix.matrix[ 5] * other[ 4] + matrix.matrix[ 6] * other[ 8] + matrix.matrix[ 7] * other[12]
  matrix.tmp[ 5] = matrix.matrix[ 4] * other[ 1] + matrix.matrix[ 5] * other[ 5] + matrix.matrix[ 6] * other[ 9] + matrix.matrix[ 7] * other[13]
  matrix.tmp[ 6] = matrix.matrix[ 4] * other[ 2] + matrix.matrix[ 5] * other[ 6] + matrix.matrix[ 6] * other[10] + matrix.matrix[ 7] * other[14]
  matrix.tmp[ 7] = matrix.matrix[ 4] * other[ 3] + matrix.matrix[ 5] * other[ 7] + matrix.matrix[ 6] * other[11] + matrix.matrix[ 7] * other[15]
  matrix.tmp[ 8] = matrix.matrix[ 8] * other[ 0] + matrix.matrix[ 9] * other[ 4] + matrix.matrix[10] * other[ 8] + matrix.matrix[11] * other[12]
  matrix.tmp[ 9] = matrix.matrix[ 8] * other[ 1] + matrix.matrix[ 9] * other[ 5] + matrix.matrix[10] * other[ 9] + matrix.matrix[11] * other[13]
  matrix.tmp[10] = matrix.matrix[ 8] * other[ 2] + matrix.matrix[ 9] * other[ 6] + matrix.matrix[10] * other[10] + matrix.matrix[11] * other[14]
  matrix.tmp[11] = matrix.matrix[ 8] * other[ 3] + matrix.matrix[ 9] * other[ 7] + matrix.matrix[10] * other[11] + matrix.matrix[11] * other[15]
  matrix.tmp[12] = matrix.matrix[12] * other[ 0] + matrix.matrix[13] * other[ 4] + matrix.matrix[14] * other[ 8] + matrix.matrix[15] * other[12]
  matrix.tmp[13] = matrix.matrix[12] * other[ 1] + matrix.matrix[13] * other[ 5] + matrix.matrix[14] * other[ 9] + matrix.matrix[15] * other[13]
  matrix.tmp[14] = matrix.matrix[12] * other[ 2] + matrix.matrix[13] * other[ 6] + matrix.matrix[14] * other[10] + matrix.matrix[15] * other[14]
  matrix.tmp[15] = matrix.matrix[12] * other[ 3] + matrix.matrix[13] * other[ 7] + matrix.matrix[14] * other[11] + matrix.matrix[15] * other[15]

  matrix.matrix[ 0] = matrix.tmp[ 0]
  matrix.matrix[ 1] = matrix.tmp[ 1]
  matrix.matrix[ 2] = matrix.tmp[ 2]
  matrix.matrix[ 3] = matrix.tmp[ 3]
  matrix.matrix[ 4] = matrix.tmp[ 4]
  matrix.matrix[ 5] = matrix.tmp[ 5]
  matrix.matrix[ 6] = matrix.tmp[ 6]
  matrix.matrix[ 7] = matrix.tmp[ 7]
  matrix.matrix[ 8] = matrix.tmp[ 8]
  matrix.matrix[ 9] = matrix.tmp[ 9]
  matrix.matrix[10] = matrix.tmp[10]
  matrix.matrix[11] = matrix.tmp[11]
  matrix.matrix[12] = matrix.tmp[12]
  matrix.matrix[13] = matrix.tmp[13]
  matrix.matrix[14] = matrix.tmp[14]
  matrix.matrix[15] = matrix.tmp[15]

proc RotateZ*(matrix: PMatrix, angle: float32) =
  matrix.rz[ 0] = float32(cos(angle))
  matrix.rz[ 1] = float32(sin(angle))
  matrix.rz[ 4] = float32(-sin(angle))
  matrix.rz[ 5] = float32(cos(angle))

  matrix.Mul(matrix.rz)

proc RotateX*(matrix: PMatrix, angle: float32) =
  matrix.rx[ 5] = float32(cos(angle))
  matrix.rx[ 6] = float32(-sin(angle))
  matrix.rx[ 9] = float32(sin(angle))
  matrix.rx[10] = float32(cos(angle))

  matrix.Mul(matrix.rx)
