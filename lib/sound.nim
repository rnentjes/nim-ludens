# SoundHandler
#
# var sound = createSound()
# sound.Load("sounds/bleepbleep.ogg")
# sound.Play("sounds/bleepbleep.ogg")
#
import tables
import csfml_audio as audio

# Sound

type
  Sound* = ref object of TObject
    sounds: TTable[string, PSoundBuffer]
    buffers: seq[PSound]


proc createSound*(): Sound =
  result = Sound()
  result.sounds = initTable[string, PSoundBuffer]()
  newSeq(result.buffers, 2)

  for i in countup(0, 7):
    result.buffers.add(newSound())


method Load*(snd: Sound, soundname: string) =
  if not snd.sounds.hasKey(soundname):
    var sound =  newSoundBuffer(soundname)
    snd.sounds[soundname] = sound


method GetSound*(snd: Sound, soundname: string): PSoundBuffer =
  snd.Load(soundname)

  result = snd.sounds[soundname]


method Play*(snd: Sound, soundname: string) =
  var found = false
  for buf in snd.buffers:
    if buf != nil and buf.getStatus() == Stopped:
        buf.setBuffer(snd.GetSound(soundname))
        buf.play()
        found = true
        break;

  if not found:
    echo "Not enough sound buffers in sound.nim!"


method Dispose*(snd: Sound) =
  discard