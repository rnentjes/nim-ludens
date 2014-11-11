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
attribute float a_size;
attribute vec3 a_rotation;
attribute vec4 a_color;

uniform mat4 u_pMatrix;

varying vec4 v_color;

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

mat4 rotateX(float angle) {
    return mat4(
        vec4(1.0,          0.0,         0.0,         0.0),
        vec4(0.0,          cos(angle),  sin(angle),  0.0),
        vec4(0.0,          -sin(angle), cos(angle),  0.0),
        vec4(0.0,          0.0,         0.0,         1.0)
    );
}

mat4 rotateY(float angle) {
    return mat4(
        vec4(cos(angle),   0.0,    -sin(angle), 0.0),
        vec4(0.0,          1.0,    0.0,         0.0),
        vec4(sin(angle),   0.0,    cos(angle),  0.0),
        vec4(0.0,          0.0,    0.0,         1.0)
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
  mat4 trans = translate(a_position.x, a_position.y, a_position.z);
  mat4 rot = rotateX(a_rotation.x) * rotateY(a_rotation.y) * rotateZ(a_rotation.z);
  mat4 scale = scale(a_size);
  gl_Position = u_pMatrix * trans * rot * scale * a_coords;
  v_color = a_color;
}
  """

  frag: string = """
#version 120

#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_color;

void main() {
  gl_FragColor = v_color;
}
  """


type
  Cuber* = ref object of TObject
    mesh: PMesh

  Cube = ref object
    x,y,z,rx,ry,rz: float32
    dx,dy,dz,drx,dry,drz: float32

var
  program: PShaderProgram


proc cuberMeshSetter(program: PShaderProgram, userdata: pointer) =
  var cube: Cuber = cast[Cuber](userdata)

  program.SetUniformMatrix("u_pMatrix", ludens.projectionmatrix.Address)


proc initCuber(): Cuber =
  result = Cuber()

  if program == nil:
    program = createShaderProgram(vert, frag)

  result.mesh = createMesh(program, cuberMeshSetter, cast[pointer](result), GL_TRIANGLES,
                 @[TMeshAttr(attribute: "a_coords", numberOfElements: 3),
                   TMeshAttr(attribute: "a_position", numberOfElements: 3),
                   TMeshAttr(attribute: "a_size", numberOfElements: 1),
                   TMeshAttr(attribute: "a_rotation", numberOfElements: 3),
                   TMeshAttr(attribute: "a_color", numberOfElements: 4)
                    ] )



proc createCuber*(): Cuber =
  result = initCuber()


proc Dispose*(cube: Cuber) =
  cube.mesh.Dispose()


proc flush*(cube: Cuber) =

  cube.mesh.Draw()

  #gl.glBindTexture(GL_TEXTURE_2D, 0);


proc draw*(cube: Cuber, x,y,z,size, rx,ry,rz: float32) =
  cube.mesh.AddVertices(   -1'f32,   -1'f32,  -1'f32,  x,  y,  z,  size,  rx,  ry,  rz , 1'f32, 0'f32, 0'f32, 1'f32)
  cube.mesh.AddVertices(   +1'f32,   -1'f32,  -1'f32,  x,  y,  z,  size,  rx,  ry,  rz , 1'f32, 0'f32, 0'f32, 1'f32)
  cube.mesh.AddVertices(   +1'f32,   +1'f32,  -1'f32,  x,  y,  z,  size,  rx,  ry,  rz , 1'f32, 0'f32, 0'f32, 1'f32)

  if cube.mesh.BufferFull:
    cube.flush()

  cube.mesh.AddVertices(   +1'f32,   +1'f32,  -1'f32,  x,  y,  z,  size,  rx,  ry,  rz , 1'f32, 0'f32, 0'f32, 1'f32)
  cube.mesh.AddVertices(   -1'f32,   +1'f32,  -1'f32,  x,  y,  z,  size,  rx,  ry,  rz , 1'f32, 0'f32, 0'f32, 1'f32)
  cube.mesh.AddVertices(   -1'f32,   -1'f32,  -1'f32,  x,  y,  z,  size,  rx,  ry,  rz , 1'f32, 0'f32, 0'f32, 1'f32)

  if cube.mesh.BufferFull:
    cube.flush()

  cube.mesh.AddVertices(   -1'f32,   -1'f32,  -1'f32,  x,  y,  z,  size,  rx,  ry,  rz , 0'f32, 1'f32, 0'f32, 1'f32)
  cube.mesh.AddVertices(   -1'f32,   -1'f32,   1'f32,  x,  y,  z,  size,  rx,  ry,  rz , 0'f32, 1'f32, 0'f32, 1'f32)
  cube.mesh.AddVertices(   -1'f32,    1'f32,  -1'f32,  x,  y,  z,  size,  rx,  ry,  rz , 0'f32, 1'f32, 0'f32, 1'f32)

  if cube.mesh.BufferFull:
    cube.flush()

  cube.mesh.AddVertices(   -1'f32,    1'f32,  -1'f32,  x,  y,  z,  size,  rx,  ry,  rz , 0'f32, 1'f32, 0'f32, 1'f32)
  cube.mesh.AddVertices(   -1'f32,    1'f32,   1'f32,  x,  y,  z,  size,  rx,  ry,  rz , 0'f32, 1'f32, 0'f32, 1'f32)
  cube.mesh.AddVertices(   -1'f32,   -1'f32,   1'f32,  x,  y,  z,  size,  rx,  ry,  rz , 0'f32, 1'f32, 0'f32, 1'f32)

  if cube.mesh.BufferFull:
    cube.flush()

  cube.mesh.AddVertices(   -1'f32,   -1'f32,   1'f32,  x,  y,  z,  size,  rx,  ry,  rz , 0'f32, 0'f32, 1'f32, 1'f32)
  cube.mesh.AddVertices(    1'f32,    1'f32,   1'f32,  x,  y,  z,  size,  rx,  ry,  rz , 0'f32, 0'f32, 1'f32, 1'f32)
  cube.mesh.AddVertices(   -1'f32,    1'f32,   1'f32,  x,  y,  z,  size,  rx,  ry,  rz , 0'f32, 0'f32, 1'f32, 1'f32)

  if cube.mesh.BufferFull:
    cube.flush()

  cube.mesh.AddVertices(   -1'f32,   -1'f32,   1'f32,  x,  y,  z,  size,  rx,  ry,  rz , 0'f32, 0'f32, 1'f32, 1'f32)
  cube.mesh.AddVertices(    1'f32,    1'f32,   1'f32,  x,  y,  z,  size,  rx,  ry,  rz , 0'f32, 0'f32, 1'f32, 1'f32)
  cube.mesh.AddVertices(    1'f32,   -1'f32,   1'f32,  x,  y,  z,  size,  rx,  ry,  rz , 0'f32, 0'f32, 1'f32, 1'f32)

  if cube.mesh.BufferFull:
    cube.flush()

  cube.mesh.AddVertices(    1'f32,   -1'f32,   1'f32,  x,  y,  z,  size,  rx,  ry,  rz , 1'f32, 0'f32, 1'f32, 1'f32)
  cube.mesh.AddVertices(    1'f32,    1'f32,   1'f32,  x,  y,  z,  size,  rx,  ry,  rz , 1'f32, 0'f32, 1'f32, 1'f32)
  cube.mesh.AddVertices(    1'f32,    1'f32,  -1'f32,  x,  y,  z,  size,  rx,  ry,  rz , 1'f32, 0'f32, 1'f32, 1'f32)

  if cube.mesh.BufferFull:
    cube.flush()

  cube.mesh.AddVertices(    1'f32,    1'f32,  -1'f32,  x,  y,  z,  size,  rx,  ry,  rz , 1'f32, 0'f32, 1'f32, 1'f32)
  cube.mesh.AddVertices(    1'f32,   -1'f32,  -1'f32,  x,  y,  z,  size,  rx,  ry,  rz , 1'f32, 0'f32, 1'f32, 1'f32)
  cube.mesh.AddVertices(    1'f32,   -1'f32,   1'f32,  x,  y,  z,  size,  rx,  ry,  rz , 1'f32, 0'f32, 1'f32, 1'f32)

  if cube.mesh.BufferFull:
    cube.flush()

  cube.mesh.AddVertices(    1'f32,    1'f32,   1'f32,  x,  y,  z,  size,  rx,  ry,  rz , 1'f32, 1'f32, 0'f32, 1'f32)
  cube.mesh.AddVertices(   -1'f32,    1'f32,   1'f32,  x,  y,  z,  size,  rx,  ry,  rz , 1'f32, 1'f32, 0'f32, 1'f32)
  cube.mesh.AddVertices(   -1'f32,    1'f32,  -1'f32,  x,  y,  z,  size,  rx,  ry,  rz , 1'f32, 1'f32, 0'f32, 1'f32)

  if cube.mesh.BufferFull:
    cube.flush()

  cube.mesh.AddVertices(   -1'f32,    1'f32,  -1'f32,  x,  y,  z,  size,  rx,  ry,  rz , 1'f32, 1'f32, 0'f32, 1'f32)
  cube.mesh.AddVertices(    1'f32,    1'f32,  -1'f32,  x,  y,  z,  size,  rx,  ry,  rz , 1'f32, 1'f32, 0'f32, 1'f32)
  cube.mesh.AddVertices(    1'f32,    1'f32,   1'f32,  x,  y,  z,  size,  rx,  ry,  rz , 1'f32, 1'f32, 0'f32, 1'f32)

  if cube.mesh.BufferFull:
    cube.flush()

  cube.mesh.AddVertices(    1'f32,   -1'f32,   1'f32,  x,  y,  z,  size,  rx,  ry,  rz , 0'f32, 1'f32, 1'f32, 1'f32)
  cube.mesh.AddVertices(   -1'f32,   -1'f32,   1'f32,  x,  y,  z,  size,  rx,  ry,  rz , 0'f32, 1'f32, 1'f32, 1'f32)
  cube.mesh.AddVertices(   -1'f32,   -1'f32,  -1'f32,  x,  y,  z,  size,  rx,  ry,  rz , 0'f32, 1'f32, 1'f32, 1'f32)

  if cube.mesh.BufferFull:
    cube.flush()

  cube.mesh.AddVertices(   -1'f32,   -1'f32,  -1'f32,  x,  y,  z,  size,  rx,  ry,  rz , 0'f32, 1'f32, 1'f32, 1'f32)
  cube.mesh.AddVertices(    1'f32,   -1'f32,  -1'f32,  x,  y,  z,  size,  rx,  ry,  rz , 0'f32, 1'f32, 1'f32, 1'f32)
  cube.mesh.AddVertices(    1'f32,   -1'f32,   1'f32,  x,  y,  z,  size,  rx,  ry,  rz , 0'f32, 1'f32, 1'f32, 1'f32)

  if cube.mesh.BufferFull:
    cube.flush()

