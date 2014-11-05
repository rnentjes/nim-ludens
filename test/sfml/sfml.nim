when defined(linux):
  const
    LibG = "libcsfml-graphics.so.2.(1|0)"
    LibS = "libcsfml-system.so.2.(1|0)"
    LibW = "libcsfml-window.so.2.(1|0)"
else:
  {.error: "Platform unsupported".}
{.deadCodeElim: on.}
{.pragma: pf, pure, final.}

type
  VideoMode* {.pf.} = object
    width*: cint
    height*: cint
    bitsPerPixel*: cint
  RenderWindow* = ref object
  PContextSettings* = ptr TContextSettings
  TContextSettings*{.pf.} = object
    depthBits*: cint
    stencilBits*: cint
    antialiasingLevel*: cint
    majorVersion*: cint
    minorVersion*: cint
  Window* = ptr object

const
  sfNone*         = 0
  sfTitlebar*     = 1 shl 0
  sfResize*       = 1 shl 1
  sfClose*        = 1 shl 2
  sfFullscreen*   = 1 shl 3
  sfDefaultStyle* = sfTitlebar or sfResize or sfClose

proc getVideoMode*(width, height, bpp: cint): VideoMode =
  result.width = width
  result.height = height
  result.bitsPerPixel = bpp

proc getDesktopMode*(): VideoMode {.
  cdecl, importc: "sfVideoMode_getDesktopMode", dynlib: LibW.}

proc newWindow*(mode: VideoMode, title: cstring, style: uint32, settings: PContextSettings = nil): RenderWindow {.
  importc: "sfWindow_create", dynlib: LibW.}

