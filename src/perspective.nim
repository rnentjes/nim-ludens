import math

proc DegToRad(deg: float32) :float32 =
    result = float32((deg / 180.0'f32) * PI)
        
proc OrthographicProjection*(left: float32, right: float32, bottom: float32, top: float32, near: float32, far: float32, matrix: var array[0..15, float32]) =
       
    matrix[0] = 2.0 / (right - left)
    matrix[1] = 0.0
    matrix[2] = 0.0
    matrix[3] = 0.0
   
    matrix[4] = 0.0
    matrix[5] = 2.0 / (top - bottom)
    matrix[6] = 0.0
    matrix[7] = 0.0
   
    matrix[8] = 0.0
    matrix[9] = 0.0
    matrix[10] = -2.0 / (far - near)
    matrix[11] = 0.0
   
    matrix[12] = (right + left) / (right - left)
    matrix[13] = (top + bottom) / (top - bottom)
    matrix[14] = (far + near) / (far - near)
    matrix[15] = 1.0
    
proc PerspectiveProjection*(angle: float32, imageAspectRatio: float32, near: float32, far: float32, matrix: var array[0..15, float32]) =
    var 
        r = DegToRad(angle)
        f = float32(1.0'f32 / tan(r / 2.0'f32))
        
    matrix[0] = f / imageAspectRatio
    matrix[1] = 0.0'f32
    matrix[2] = 0.0'f32
    matrix[3] = 0.0'f32
   
    matrix[4] = 0.0'f32
    matrix[5] = f
    matrix[6] = 0.0'f32
    matrix[7] = 0.0'f32
   
    matrix[8] = 0.0'f32
    matrix[9] = 0.0'f32
    matrix[10] = -(far + near) / (far - near)
    matrix[11] = -1.0'f32
   
    matrix[12] = 0.0'f32
    matrix[13] = 0.0'f32
    matrix[14] = -(2.0'f32 * far * near) / (far - near)
    matrix[15] = 0.0'f32

proc PerspectiveProjection2*(angle: float32, imageAspectRatio: float32, n: float32, f: float32) : array[0..15, float32] =

    var 
        r = DegToRad(angle)
        f = 1.0 / tan(r / 2.0)
        
    result = [float32(f / imageAspectRatio), 0.0'f32,    0.0'f32,                            0.0'f32, 
              0.0'f32,                       float32(f), 0.0'f32,                            0.0'f32, 
              0.0'f32,                       0.0'f32,    float32(-(f + n) / (f - n)),       -1.0'f32, 
              0.0'f32,                       0.0'f32,    float32(-(2.0 * f * n) / (f - n)),  0.0'f32]    
 