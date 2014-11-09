# SoundHandler
#
# var soundHandler = createSoundHandler()
# var sound = createSound("sounds/bleepbleep.ogg")
#
# soundHandler.play(sound)
#

import tables
import csfml_audio as audio

# Sound

type
  SoundPlayer* = ref object of TObject
    buffers: seq[PSound]

  Sound* = ref object of TObject
    soundBuffer: PSoundBuffer


proc createSoundPlayer*(numberOfBuffers: int = 8): SoundPlayer =
  result = SoundPlayer()

  newSeq(result.buffers, numberOfBuffers)
  for i in countup(1, numberOfBuffers):
    result.buffers.add(newSound())


proc createSound*(filename: string): Sound =
  result = Sound()
  result.soundBuffer =  newSoundBuffer(filename)


method Play*(player: SoundPlayer, snd: Sound, vol: float32 = 100) =
  var buffer: PSound = nil
  for buf in player.buffers:
    if buffer == nil and buf != nil and buf.getStatus() == Stopped:
      buffer = buf
      break;

  if buffer != nil:
    buffer.setVolume(vol)
    buffer.setBuffer(snd.soundBuffer)
    buffer.play()
  #else:
  #  echo "Not enough sound buffers in sound.nim!"


method Dispose*(soundPlayer: SoundPlayer) =
  discard


method Dispose*(sound: Sound) =
  discard
