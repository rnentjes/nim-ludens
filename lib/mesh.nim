# Mesh
import strutils

import opengl
import shaderProgram
import tables
import matrix


type
  TMesh = object
    drawType: GLenum
    data: array[0..32768, float32]
    count: int
    blockLength: int
    drawLength: int
    dataSize: int
    vertex_vbo: GLuint
    program: PShaderProgram
    setter: UniformSetter
    resetter: UniformSetter
    attrs: seq[TMeshAttr]
    attrLocations: TTable[string, GLuint]
    userdata: pointer

  PMesh* = ref TMesh

  TMeshAttr* = object
    attribute*: string
    attrIndex*: GLuint
    numberOfElements*: GLint

  PMeshAttr* = ref TMeshAttr

  UniformSetter* = proc (program: PShaderProgram, userdata: pointer)


proc createMesh*(program: PShaderProgram, setter: UniformSetter, userdata: pointer, drawType: GLenum, attribs: seq[TMeshAttr]) : PMesh =
  result = new(TMesh)

  result.drawType = drawType
  result.program = program
  result.setter = setter
  result.userdata = userdata
  result.attrs = attribs
  result.count = 0
  result.blockLength = 0
  result.attrLocations = initTable[string, GLuint]()

  for attr in attribs:
    result.attrLocations[attr.attribute] = program.GetAttribLocation(attr.attribute)
    result.blockLength = result.blockLength + attr.numberOfElements

  case drawType
    of GL_TRIANGLES:
      result.drawLength = result.blockLength * 3
    of GL_POINTS:
      result.drawLength = result.blockLength * 1
    else:
      quit("Unknown draw type " & $drawType)

  #echo "high: " & $high(result.data)
  result.dataSize = high(result.data) - (high(result.data) mod result.drawLength)

  glGenBuffers(1, addr(result.vertex_vbo))
  glBindBuffer(GL_ARRAY_BUFFER, result.vertex_vbo)
  glBufferData(GL_ARRAY_BUFFER, cast[GLsizeiptr](sizeof(GL_FLOAT) * high(result.data)), addr(result.data[0]), GL_DYNAMIC_DRAW)
  glBindBuffer(GL_ARRAY_BUFFER, 0)


proc createMesh*(program: PShaderProgram, setter: UniformSetter, resetter: UniformSetter, userdata: pointer, drawType: GLenum, attribs: seq[TMeshAttr]) : PMesh =
  result = createMesh(program, setter, userdata, drawType, attribs)
  result.resetter = resetter


proc Dispose*(mesh: PMesh) =
  discard


proc Reset*(mesh: PMesh) =
  mesh.count = 0


proc Draw*(mesh: PMesh) =
  mesh.program.Begin()

  mesh.setter(mesh.program, mesh.userdata)

  glBindBuffer(GL_ARRAY_BUFFER, mesh.vertex_vbo)

  var index = 0
  for attr in mesh.attrs:
    glEnableVertexAttribArray(mesh.attrLocations[attr.attribute])
    glVertexAttribPointer(mesh.attrLocations[attr.attribute], attr.numberOfElements,
      cGL_FLOAT, false, cast[GLsizei](mesh.blockLength * sizeof(GL_FLOAT)), cast[pointer](index * sizeof(GL_FLOAT)))
    index += attr.numberOfElements

  #glBufferData(GL_ARRAY_BUFFER, cast[GLsizeiptr](sizeof(GL_FLOAT) * mesh.count), addr(mesh.data[0]), GL_DYNAMIC_DRAW)
  glBufferSubData(GL_ARRAY_BUFFER, 0, cast[GLsizeiptr](sizeof(GL_FLOAT) * mesh.count), addr(mesh.data[0]))

  glDrawArrays(mesh.drawType, 0, cast[GLsizei](int32(mesh.count / mesh.blockLength)))

  for attr in mesh.attrs:
    glDisableVertexAttribArray(mesh.attrLocations[attr.attribute])

  glBindBuffer(GL_ARRAY_BUFFER, 0)

  if mesh.resetter != nil:
    mesh.resetter(mesh.program, mesh.userdata)

  mesh.program.Done()
  mesh.Reset


proc BufferFull*(mesh: PMesh):bool =
  result = (mesh.count == mesh.dataSize)


proc AddVertices*(mesh: PMesh, verts: varargs[float32]) =
  assert len(verts) == mesh.blockLength
  assert len(verts) + mesh.count <= mesh.dataSize

  for v in verts:
    mesh.data[mesh.count] = v
    mesh.count = mesh.count + 1

  if mesh.BufferFull:
    mesh.Draw()
