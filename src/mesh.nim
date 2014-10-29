# Mesh

import opengl
import shaderProgram
import tables
import matrix

type
  TMesh = object
    drawType: GLenum
    data: array[0..4096, float32]
    count: GLsizei
    blockLength: GLsizei
    vertex_vbo: GLuint
    program: PShaderProgram
    setter: UniformSetter
    attrs: seq[TMeshAttr]
    attrLocations: TTable[string, GLuint]

  PMesh* = ref TMesh

  TMeshAttr* = object
    attribute*: string
    attrIndex*: GLuint
    numberOfElements*: GLint

  PMeshAttr* = ref TMeshAttr

  UniformSetter* = proc (program: PShaderProgram)

proc createMesh*(program: PShaderProgram, setter: UniformSetter, drawType: GLenum, attribs: seq[TMeshAttr]) : PMesh =
  result = new(TMesh)

  result.drawType = drawType
  result.program = program
  result.setter = setter
  result.attrs = attribs
  result.count = 0
  result.blockLength = 0
  result.attrLocations = initTable[string, GLuint]()

  for attr in attribs:
    result.attrLocations[attr.attribute] = program.GetAttribLocation(attr.attribute)
    result.blockLength = result.blockLength + attr.numberOfElements

  glGenBuffers(1, addr(result.vertex_vbo))
  glBindBuffer(GL_ARRAY_BUFFER, result.vertex_vbo)
  glBufferData(GL_ARRAY_BUFFER, sizeof(GL_FLOAT) * result.data.len, addr(result.data[0]), GL_DYNAMIC_DRAW)

proc Reset*(mesh: PMesh) =
  mesh.count = 0

proc Draw*(mesh: PMesh) =
  mesh.program.Begin()

  mesh.setter(mesh.program)

  glBindBuffer(GL_ARRAY_BUFFER, mesh.vertex_vbo)

  var index = 0
  for attr in mesh.attrs:
    glEnableVertexAttribArray(mesh.attrLocations[attr.attribute])
    glVertexAttribPointer(mesh.attrLocations[attr.attribute], attr.numberOfElements, 
      cGL_FLOAT, false, cast[GLsizei](mesh.blockLength * sizeof(GL_FLOAT)), cast[pointer](index * sizeof(GL_FLOAT)))
    index += attr.numberOfElements
 
  glBufferSubData(GL_ARRAY_BUFFER, 0, cast[GLsizeiptr](sizeof(GL_FLOAT) * int(mesh.count)), addr(mesh.data[0]))

  glDrawArrays(mesh.drawType, 0, cast[GLsizei](uint(mesh.count / mesh.blockLength)))

  for attr in mesh.attrs:
    glDisableVertexAttribArray(mesh.attrLocations[attr.attribute])

  glBindBuffer(GL_ARRAY_BUFFER, 0)

  mesh.program.Done()
  mesh.Reset

proc AddVertices*(mesh: PMesh, verts: varargs[float32]) =
  assert verts.len == mesh.blockLength
  #assert (verts.len + mesh.count) < mesh.len
  if (mesh.count + verts.len > 4000):
    mesh.Draw

  for v in verts:
    mesh.data[mesh.count] = v
    mesh.count = mesh.count + 1

