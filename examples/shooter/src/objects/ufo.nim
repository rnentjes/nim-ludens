import sprite
import math

type
  Wave* = ref object of RootObj
    time: float32
    x,y: float32

  SimpleWave = ref object of Wave

  Ufo* = ref object of Sprite
    wave: Wave
    number: int

proc createSimpleWave*(): SimpleWave =
  result = SimpleWave()
  result.time = 0

proc Time*(wave: Wave): float32 =
  result = wave.time

method Update*(wave: Wave, delta:float32) =
  wave.time += delta

  wave.x = sin(wave.time * 13 / 5) * 30
  wave.y = sin(wave.time * 21 / 5) * 40

method OffsetX(wave: Wave, number: int): float32 =
  var xo = number mod 8

  result = float(-210 + xo * 60) + wave.x


method OffsetY(wave: Wave, number: int): float32 =
  var yo = int(number / 8)

  result = float(320 - yo * 60) + wave.y


method GetX*(wave: Wave, number: int): float32 =
  result = wave.OffsetX(number)

method GetY*(wave: Wave, number: int): float32 =
  result = wave.OffsetY(number)

  var yo = 400 - (wave.time - float32(31-number) / 8) * 400
  yo = max(yo, 0)

  result = result + yo


method Update*(ufo: Ufo, delta: float32) =
  ufo.X(ufo.wave.GetX(ufo.number))
  ufo.Y(ufo.wave.GetY(ufo.number))


proc createUfo*(wave: Wave, nr: int): Ufo =
  result = Ufo(wave: wave, number: nr)
  result.Y(-500)